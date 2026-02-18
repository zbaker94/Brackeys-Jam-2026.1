#item interaction using a buttton stop & start
extends Sprite2D
var speed = 400
var angular_speed = PI
const SPEED:int = 50 
var has_mouse:bool = false

func _on_area_2d_mouse_entered():
	has_mouse = true
func _on_area_2d_exited():
	has_mouse = false


func _ready() -> void:
	pass

#func _process(delta):
#	if Input.is_action_just_pressed("left_clicked"):
#		global_position = global_position.lerp(get_global_mouse_position, SPEED * delta)
