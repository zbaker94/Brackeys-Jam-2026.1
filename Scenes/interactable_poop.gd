extends Interactable

@onready var parent_body: RigidBody3D = $".."

@export var drag_snap_depth: float = 0.5

@export var drag_spring_strength: float = 50.0
@export var drag_damping: float = 5.0

var cached_velocity: Vector3 = Vector3.ZERO

var dragging: bool = false

func _on_click():
	print_debug("Clicked on poop!")
	
func _on_drag(start_position: Vector2, current_position: Vector2, drag_distance: float):
	print_debug("Dragging poop from ", start_position, " to ", current_position, " with distance: ", drag_distance)
	dragging = true	
	
func _on_drop(start_position: Vector2, end_position: Vector2, drag_distance: float):
	print_debug("Dropped poop at position: ", end_position, " with distance: ", drag_distance)
	dragging = false

func _on_hover():
	pass

	
func _on_hover_exit():
	pass


func _physics_process(_delta: float) -> void:
	
	if dragging == true:
		var camera := get_viewport().get_camera_3d()
	
		var mouse_pos = get_viewport().get_mouse_position()
		
		#parent_body.global_position.z = drag_snap_depth
		
		var object_in_camera_space = camera.global_transform.affine_inverse() * parent_body.global_position
		var depth = -object_in_camera_space.z
		
		var target_pos = camera.project_position(mouse_pos, depth)
		target_pos.z = drag_snap_depth
		
		var offset = target_pos - parent_body.global_position
		var spring_force = offset * drag_spring_strength
		
		var damping_force = -parent_body.linear_velocity * drag_damping
		
		parent_body.apply_central_force(spring_force + damping_force)
	
	
