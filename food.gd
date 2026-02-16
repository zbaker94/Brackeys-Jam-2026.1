extends Sprite2D
var speed = 400
var angular_speed = PI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	rotation += angular_speed* delta
	var velocity = Vector2.UP.rotated(rotation) * speed
	position += velocity * delta
func _on_button_pressed():
	set_process(not is_processing())
