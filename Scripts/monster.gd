# starts and stops timer for attributes; custom cursor  
extends Node 

var global_stats: GlobalStats

#@onready var _idle = $AnimatedSprite2D
#@onready var _health = $AnimatedSprite2D2

func on_hunger_change(new_value: float) -> void:
	if new_value == 0:
		global_stats.set_stat_current_value("health", 50)
	elif new_value <= 25:
		print("im not feeling too good")
	else:
		print("Im prerfectly fine")

func on_stat_change(stat_name: String, new_value: float) -> void:
		if stat_name == "hunger":
			on_hunger_change(new_value)
		elif stat_name == "health":
			print_debug("health set to " + str(new_value))

func _ready():
	global_stats = $"../GlobalStats"
	#global_stats.timer_start.connect(func(timer_name: String): print("timer started with name " + timer_name))
	
	global_stats.stat_changed.connect(on_stat_change)
	
	#if Global.health and Global.hunger <= 25:
		#print("im not feeling too good")
		#_health.play("health") 
		#_idle.play("idle")
		#
	#else:
		#print("Im prerfectly fine")
		#_idle.play("idle")

#func _process(_delta):
	#$hunger.value = $Timer.time_left 
	#
		#
#
#func _on_timer_timeout():
	#print("TIMER done ")
	#print("your hunger is:"+ str(Global.hunger)) 
	#$Timer.start()	
	#Global.hunger -=25
	









# TODO:
# Hunger ticks down over time (done?)
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
