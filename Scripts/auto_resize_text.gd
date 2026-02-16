extends RichTextLabel

signal typewriter_finished

@export var minimum_font_size: int = 12
@export var maximum_font_size: int = 120
@export var debug_print: bool = true
@export var extra_padding_x: float = 0.0
@export var extra_padding_y: float = 0.0
@export var char_delay_map: CharacterDelayMap
@export var enable_bbcode: bool = false
@export var allow_skip_typewriter: bool = true

# Internal state
var _text_cache: Dictionary = {}
var _cached_font_size: int = -1
var _typewriter_active: bool = false
var _typewriter_time_accumulator: float = 0.0
var _typewriter_sequence: Array = []
var _typewriter_step_index: int = 0
var _current_speed_multiplier: float = 1.0

func _ready() -> void:
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bbcode_enabled = enable_bbcode
	call_deferred("_deferred_setup")

func _set(property: StringName, _value: Variant) -> bool:
	if property == "text":
		_text_cache.clear()
		_cached_font_size = -1
	return false

func _process(delta: float) -> void:
	if not _typewriter_active:
		return
	
	# Check for skip input
	if allow_skip_typewriter and Input.is_action_just_pressed("skip_text"):
		_skip_typewriter()
		return
	
	_typewriter_time_accumulator += delta
	
	while _typewriter_active and _typewriter_step_index < _typewriter_sequence.size():
		var step = _typewriter_sequence[_typewriter_step_index]
		var required_delay := 0.0
		
		if step["type"] == "pause":
			var base := char_delay_map.base_delay if char_delay_map else 0.04
			var char_delay := char_delay_map.get_delay(step["pause_str"], _current_speed_multiplier) if char_delay_map else 0.0
			required_delay = (base / _current_speed_multiplier) + char_delay
		elif step["type"] == "speed":
			# Speed changes are instant
			_current_speed_multiplier = step["multiplier"]
			_typewriter_step_index += 1
			continue
		elif step["type"] == "char":
			visible_characters = step["char_position"] + 1
			var base := char_delay_map.base_delay if char_delay_map else 0.04
			var char_delay := char_delay_map.get_delay(step["char"], _current_speed_multiplier) if char_delay_map else 0.0
			required_delay = (base / _current_speed_multiplier) + char_delay
		
		if _typewriter_time_accumulator >= required_delay:
			_typewriter_time_accumulator -= required_delay
			_typewriter_step_index += 1
		else:
			# Not enough time accumulated yet, wait for next frame
			break
	
	# Check if we finished
	if _typewriter_step_index >= _typewriter_sequence.size():
		_finish_typewriter()

func _deferred_setup() -> void:
	var typewriter_data = _parse_text_for_typewriter(text)
	text = typewriter_data["display_text"]
	await _recalculate_font_size()
	_start_typewriter_effect(typewriter_data)
	resized.connect(call_deferred_fit)

func call_deferred_fit() -> void:
	if _typewriter_active:
		# Save typewriter state before recalculating
		var saved_step_index := _typewriter_step_index
		var saved_time_accumulator := _typewriter_time_accumulator
		var saved_speed_multiplier := _current_speed_multiplier
		var saved_sequence := _typewriter_sequence.duplicate()
		var saved_visible_characters := visible_characters
		_typewriter_active = false
		
		await _recalculate_font_size()
		
		# Restore typewriter state
		_typewriter_sequence = saved_sequence
		_typewriter_step_index = saved_step_index
		_typewriter_time_accumulator = saved_time_accumulator
		_current_speed_multiplier = saved_speed_multiplier
		visible_characters = saved_visible_characters
		_typewriter_active = true
		
		if debug_print:
			print("Resize: recalculated font size to ", _cached_font_size, ", preserved typewriter at step ", saved_step_index)
	else:
		# Typewriter finished or not started, just recalculate font size
		await _recalculate_font_size()
		visible_ratio = 1.0  # Show all text

func _recalculate_font_size() -> void:
	"""Binary search to find optimal font size for current text and container size"""
	visible_ratio = 0
	
	# Explicitly type the font variable to avoid Variant inference
	var font: Font = get_theme_font("normal_font")
	if font == null:
		if debug_print:
			print("_recalculate_font_size: no theme font found")
		return

	var available_w: float = max(0.0, size.x - extra_padding_x)
	var available_h: float = max(0.0, size.y - extra_padding_y)

	if debug_print:
		print("_recalculate_font_size start: control size=", size, " avail=", Vector2(available_w, available_h))

	if available_w <= 0.0 or available_h <= 0.0:
		if debug_print:
			print("_recalculate_font_size: available area <= 0, skipping")
		return

	var lo: int = minimum_font_size
	var hi: int = maximum_font_size
	var best: int = lo

	while lo <= hi:
		var mid: int = (lo + hi) >> 1
		add_theme_font_size_override("normal_font_size", mid)

		# Wait for layout to update (one frame is sufficient)
		await get_tree().process_frame

		var content_w: float = get_content_width()
		var content_h: float = get_content_height()

		if debug_print:
			print("test size=", mid, " content=", Vector2(content_w, content_h), " avail=", Vector2(available_w, available_h))

		if content_w <= available_w and content_h <= available_h:
			best = mid
			lo = mid + 1
		else:
			hi = mid - 1

	add_theme_font_size_override("normal_font_size", best)
	_cached_font_size = best
	
	if debug_print:
		print("_recalculate_font_size done: best=", best)


func _start_typewriter_effect(typewriter_data: Dictionary) -> void:
	"""Start typewriter animation with parsed sequence data"""
	visible_characters = 0
	_typewriter_sequence = typewriter_data["sequence"]
	_typewriter_step_index = 0
	_typewriter_time_accumulator = 0.0
	_current_speed_multiplier = 1.0
	_typewriter_active = true
	
	if debug_print:
		print("Typewriter started with ", _typewriter_sequence.size(), " steps")

func _skip_typewriter() -> void:
	"""Instantly complete typewriter animation"""
	visible_ratio = 1.0
	_finish_typewriter()
	if debug_print:
		print("Typewriter skipped")

func _finish_typewriter() -> void:
	"""Clean up typewriter state and emit completion signal"""
	_typewriter_active = false
	_typewriter_sequence.clear()
	typewriter_finished.emit()
	if debug_print:
		print("Typewriter finished")

func _parse_text_for_typewriter(source_text: String) -> Dictionary:
	"""Parse text into sequence of displayable characters and control commands. Returns {sequence: Array, display_text: String}"""
	# Check cache first
	var cache_key := str(source_text.hash())
	if char_delay_map:
		cache_key += "_" + str(char_delay_map.get_instance_id())
	cache_key += "_bbcode_" + str(enable_bbcode)
	
	if _text_cache.has("key") and _text_cache["key"] == cache_key:
		if debug_print:
			print("Using cached parse result")
		return _text_cache["result"]
	
	var sequence := []
	var display_text := ""
	var char_position := 0  # Tracks displayable character position
	var i := 0
	
	while i < source_text.length():
		# Check for custom control sequences first (highest priority)
		if source_text[i] == '{':
			var end_idx = source_text.find("}", i)
			if end_idx != -1:
				var control_seq = source_text.substr(i, end_idx - i + 1)
				
				# Check if it's a pause sequence
				if control_seq == "{pause}" or (control_seq.begins_with("{pause_") and control_seq.ends_with("}")):
					sequence.append({
						"type": "pause",
						"pause_str": control_seq,
						"char_position": char_position
					})
					i = end_idx + 1
					continue
				
				# Check if it's a speed sequence
				if char_delay_map:
					var speed_mult = char_delay_map.parse_speed_sequence(control_seq)
					if speed_mult >= 0:
						sequence.append({
							"type": "speed",
							"multiplier": speed_mult,
							"char_position": char_position
						})
						i = end_idx + 1
						continue
		
		# Check for BBCode tags (preserve in output, don't count as characters)
		if enable_bbcode and source_text[i] == '[':
			var end_idx = source_text.find("]", i)
			if end_idx != -1:
				var tag = source_text.substr(i, end_idx - i + 1)
				display_text += tag
				i = end_idx + 1
				continue
		
		# Regular displayable character
		sequence.append({
			"type": "char",
			"char": source_text[i],
			"char_position": char_position
		})
		display_text += source_text[i]
		char_position += 1
		i += 1
	
	var result = {"sequence": sequence, "display_text": display_text}
	
	# Cache the result
	_text_cache = {
		"key": cache_key,
		"result": result
	}
	
	if debug_print:
		print("Parsed text: ", char_position, " displayable chars, ", sequence.size(), " total steps")
	
	return result
