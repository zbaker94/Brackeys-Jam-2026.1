# starts and stops timer for attributes; custom cursor  
extends Node 

var global_stats: GlobalStats
var poop = preload("res://poop.tscn")


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
	

func inst(pos):
	var instance = poop.instantiate()
	instance.position = pos 
	add_child(instance)
	

func _physics_process(delta):
	if Input.is_action_just_pressed("poop spawn"):
		var poop_location = inst(Vector3(-0.3,0.2,0.3))
		print("poop spawned at" + str(poop_location))









# TODO:
# Food pipe emitting signal waiting for food item
# When food bar gets to certain point play hunger animation
# When food gets added to pipe fill back food bar (possibly reset the timer?)
# Click and drag food item to food pipe 
# change form from mon1 to mon2 
# Spawn poop on screen
# Drag to poop bucket 
# If to many spawns
# Play stink animation

# If poop and food are down tick health down over time stop once poop < 4
# Emit signal for wash rag from bucket
# Grab wash rag from bucket click on monster
# If moster ate food and washrag was used increase health 
