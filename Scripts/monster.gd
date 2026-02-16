# starts and stops timer for attributes  
extends CharacterBody2D
@onready var _idle = $AnimatedSprite2D
@onready var _health = $AnimatedSprite2D2
var health = 100
var hunger = 100
var activity = 100

var monster_atts = [health,hunger,activity]

func _ready():
	$Timer.start()
	$Timer.wait_time = health
	
	print("your time has started now")

func life_change(health):
	$health.value = health

func _process(_delta):
	$health.value = $Timer.time_left 
	if $Timer.time_left <= 50:
		print("im not feeling too good")
		_health.play("health") 
		_idle.play("idle")
		
	else:
		print("Im prerfectly fine")
		_idle.play("idle")
		
		
func _on_timer_timeout():
	print("TIMER ")
	health -= 0.5
	print (health)
	$Timer.start()


# TODO:

# health loss if hunger and being bored gets too low
# clickable & drag item to monster
# animations for low resources
# custom crusor
# day cycle
# game end results