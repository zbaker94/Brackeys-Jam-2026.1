extends Resource
class_name CharacterDelayMap

@export var base_delay: float = 0.04
@export var pause_delay: float = 0.1
@export var char_delays: Dictionary = {
	".": 0.40,
	",": 0.20,
	"\n": 0.18,
	"!": 0.30,
	"?": 0.30
}
@export var speed_presets: Dictionary = {
	"fast": 3.0,
	"slow": 0.5,
	"instant": 999.0
}

## Get the delay for a character, applying the current speed multiplier.
## speed_multiplier: Higher values = faster (divide delay), e.g. 2.0 = 2x speed (half delay)
func get_delay(character: String, speed_multiplier: float = 1.0) -> float:
	var delay := 0.0
	
	if character == "{pause}":
		delay = pause_delay
	elif character.begins_with("{pause_") and character.ends_with("}"):
		# Support {pause_N} where N is a positive number
		var num_str = character.substr(7, character.length() - 8)
		var n = float(num_str)
		if n > 0:
			delay = pause_delay * n
		else:
			push_warning("Invalid pause value (must be > 0): " + character)
			delay = 0.0
	else:
		delay = char_delays.get(character, 0.0)
	
	# Apply speed multiplier (higher = faster = less delay)
	if speed_multiplier > 0:
		return delay / speed_multiplier
	else:
		return delay

## Parse a control sequence and return speed multiplier change, or -1 if not a speed command
func parse_speed_sequence(sequence: String) -> float:
	if sequence == "{speed_reset}":
		return 1.0
	elif speed_presets.has(sequence.trim_prefix("{").trim_suffix("}")):
		var preset_name = sequence.trim_prefix("{").trim_suffix("}")
		return speed_presets[preset_name]
	elif sequence.begins_with("{speed_") and sequence.ends_with("}"):
		var num_str = sequence.substr(7, sequence.length() - 8)
		var multiplier = float(num_str)
		if multiplier > 0:
			return multiplier
		else:
			push_warning("Invalid speed multiplier (must be > 0): " + sequence)
			return -1.0
	return -1.0
