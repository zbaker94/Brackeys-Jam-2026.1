extends RichTextLabel

@export var minimum_font_size: int = 12
@export var maximum_font_size: int = 120
@export var debug_print: bool = true
@export var extra_padding_x: float = 0.0
@export var extra_padding_y: float = 0.0
@export var char_delay_map: CharacterDelayMap

func _ready() -> void:
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	call_deferred("_deferred_setup")

func _deferred_setup() -> void:
	call_deferred("fit_text")
	resized.connect(call_deferred_fit)

func call_deferred_fit() -> void:
	call_deferred("fit_text")

func fit_text() -> void:
	visible_ratio = 0
	
	# Explicitly type the font variable to avoid Variant inference
	var font: Font = get_theme_font("normal_font")
	if font == null:
		if debug_print:
			print("fit_text: no theme font found for key 'normal_font'")
		return

	var available_w: float = max(0.0, size.x - extra_padding_x)
	var available_h: float = max(0.0, size.y - extra_padding_y)

	if debug_print:
		print("fit_text start: control size=", size, "avail=", Vector2(available_w, available_h))

	if available_w <= 0.0 or available_h <= 0.0:
		if debug_print:
			print("fit_text: available area <= 0, skipping")
		return

	var lo: int = minimum_font_size
	var hi: int = maximum_font_size
	var best: int = lo

	while lo <= hi:
		var mid: int = (lo + hi) >> 1
		add_theme_font_size_override("normal_font_size", mid)

		# wait for layout to update — two frames to be safe
		await get_tree().process_frame
		await get_tree().process_frame

		var content_w: float = get_content_width()
		var content_h: float = get_content_height()

		if debug_print:
			print("test size=", mid, "content=", Vector2(content_w, content_h), "avail=", Vector2(available_w, available_h))

		if content_w <= available_w and content_h <= available_h:
			best = mid
			lo = mid + 1
		else:
			hi = mid - 1

	add_theme_font_size_override("normal_font_size", best)
	if debug_print:
		print("fit_text done: best=", best)
		
	# Typewriter effect: animate visible_characters with pauses for periods and line breaks
	start_typewriter_effect()


func start_typewriter_effect() -> void:
	visible_characters = 0
	# Preprocess text to find displayable characters and pause markers
	var parsed = _parse_text_for_typewriter(text)
	# Set the label's text to the displayable string (without pause markers)
	text = parsed["display_text"]
	call_deferred("_typewriter_coroutine", parsed)


func _typewriter_coroutine(parsed: Dictionary) -> void:
		var base_delay := 0.04
		if char_delay_map and char_delay_map.has_method("get_delay"):
			base_delay = char_delay_map.base_delay
		var steps: Array = parsed["steps"]
		var display_count := 0
		for step in steps:
			if step["type"] == "pause":
				var delay := base_delay
				if char_delay_map and char_delay_map.has_method("get_delay"):
					delay += char_delay_map.get_delay(step["pause_str"])
				await get_tree().create_timer(delay).timeout
			elif step["type"] == "char":
				display_count += 1
				visible_characters = display_count
				var delay := base_delay
				if char_delay_map and char_delay_map.has_method("get_delay"):
					delay += char_delay_map.get_delay(step["char"])
				await get_tree().create_timer(delay).timeout

func _parse_text_for_typewriter(src: String) -> Dictionary:
	var steps := []
	var display_text := ""
	var i := 0
	var prev_char := ""
	while i < src.length():
		# Check for {pause} or {pause_N}
		if src.substr(i, 7) == "{pause}" :
			steps.append({"type": "pause", "pause_str": "{pause}"})
			i += 7
			continue
		elif src.substr(i, 7) == "{pause_":
			var end_idx = src.find("}", i)
			if end_idx != -1:
				var pause_str = src.substr(i, end_idx - i + 1)
				steps.append({"type": "pause", "pause_str": pause_str})
				i = end_idx + 1
				continue
	   # Otherwise, it's a displayable character
		steps.append({"type": "char", "char": src[i], "prev_char": prev_char})
		display_text += src[i]
		prev_char = src[i]
		i += 1
	return {"steps": steps, "display_text": display_text}
