# starts and stops timer for attributes; custom cursor  
extends Node 

var global_stats: GlobalStats

func on_hunger_change(new_value: float) -> void:
	if new_value == 0:
		print("im starving: " + str(new_value))
	elif new_value <= 25:
		print("im not feeling too good: " + str(new_value))
	elif new_value <= 75:
		print("I could eat: " + str(new_value))
	else:
		print("Im perfectly fine: " + str(new_value))

func on_stat_change(stat_name: String, new_value: float) -> void:
		if stat_name == "hunger":
			on_hunger_change(new_value)
		elif stat_name == "health":
			print_debug("health set to " + str(new_value))

func _ready():
	global_stats = $"../GlobalStats"
	global_stats.stat_changed.connect(on_stat_change)
