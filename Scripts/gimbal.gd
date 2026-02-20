extends Node3D

@export var x_rotation_range: float = 30.0  # Max rotation in degrees for X axis
@export var y_rotation_range: float = 30.0  # Max rotation in degrees for Y axis
@export var smoothing: float = 5.0  # Higher = more responsive, lower = smoother

var target_rotation := Vector3.ZERO

func _ready():
	# Assert that our child is a camera
	assert(get_child(0) is Camera3D, "Gimbal must have a Camera3D as its first child.")

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	
	var normalized_x = (mouse_pos.x / viewport_size.x) * 2.0 - 1.0
	var normalized_y = (mouse_pos.y / viewport_size.y) * 2.0 - 1.0

	var z_rotation = -normalized_x * deg_to_rad(1.2)
	
	target_rotation.x = -normalized_y * deg_to_rad(x_rotation_range)
	target_rotation.y = -normalized_x * deg_to_rad(y_rotation_range)
	target_rotation.z = z_rotation
	
	rotation = rotation.lerp(target_rotation, smoothing * delta)
