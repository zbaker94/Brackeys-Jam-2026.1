# starts a timer and triggers an end 
extends CharacterBody2D
var health = 100
var hunger = 100
var activity = 5
var monster_atts = [health,hunger,activity]

func _ready():
	$Timer.start()
	$Timer.wait_time = health
	print("your time has started now")

#func hunger_change(hunger):
#	$hunger.value = hunger
#func _process_hunger(_delta):
#	$hunger.value = $Timer.time_left 
#	if $hunger.value <= 50:
#		print("im now hungry")

func life_change(health):
	$health.value = health

func _process(_delta):
	$health.value = $Timer.time_left 
	if $Timer.time_left <= 50:
		print("im hungry boss")
	else:
		print("Im prerfectly fine")




	#check for monster attributes
	#tick down attributes over time
	
	#if health & hunger < 5
		#play hunger animation
	#else activity < 5 
		#play bored
	
	
		
func _on_timer_timeout():
	print("TIMER ")
	health -= 0.5
	print (health)
	$Timer.start()
