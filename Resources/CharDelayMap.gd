extends Resource
class_name CharacterDelayMap

@export var base_delay: float = 0.04
@export var pause_delay: float = 0.1
@export var char_delays: Dictionary = {
	".": 0.40,
	",": 0.20,
	"\n": 0.18,
	"!": 0.30,
	"?": 0.30,
	"{pause}": 0.7
}

func get_delay(character: String) -> float:
	if character == "{pause}":
		return pause_delay
   # Support {pause_N} where N is a number
	if character.begins_with("{pause_") and character.ends_with("}"):
		var num_str = character.substr(7, character.length() - 8)
		var n = int(num_str)
		if n > 0:
			return pause_delay * n
	return char_delays.get(character, 0.0)
