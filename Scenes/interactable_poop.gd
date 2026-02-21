extends Interactable

@onready var parent_body: RigidBody3D = $".."

var cached_velocity: Vector3 = Vector3.ZERO

func _on_click():
	print_debug("Clicked on poop!")
	
func _on_drag(start_position: Vector2, current_position: Vector2, drag_distance: float):
	print_debug("Dragging poop from ", start_position, " to ", current_position, " with distance: ", drag_distance)
	
func _on_drop(start_position: Vector2, end_position: Vector2, drag_distance: float):
	print_debug("Dropped poop at position: ", end_position, " with distance: ", drag_distance)
	parent_body.freeze = false

func _on_hover():
	cached_velocity = parent_body.linear_velocity
	parent_body.freeze = true

	
func _on_hover_exit():
	parent_body.freeze = false
	parent_body.linear_velocity = cached_velocity

	
	
