# starts and stops timer for attributes; custom cursor  
extends CharacterBody2D 



@onready var _idle = $AnimatedSprite2D
@onready var _health = $AnimatedSprite2D2

func _ready():
	Input.set_custom_mouse_cursor(Global.arrow)
	$Timer.start()
	$Timer.wait_time = 105
	print("your time has started now")
	
	if Global.health and Global.hunger <= 25:
		print("im not feeling too good")
		_health.play("health") 
		_idle.play("idle")
		
	else:
		print("Im prerfectly fine")
		_idle.play("idle")

func _process(_delta):
	$hunger.value = $Timer.time_left 
	
		

func _on_timer_timeout():
	print("TIMER done ")
	print("your hunger is:"+ str(Global.hunger)) 
	$Timer.start()	
	Global.hunger -=25
	









# TODO:
# Hunger ticks down over time (done?)
# Food pipe emitting signal waiting for food item
# When food bar gets to certain point play hunger animation
# When food gets added to pipe fill back food bar
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
