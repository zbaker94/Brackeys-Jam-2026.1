extends Interactable

@export var spot_light: SpotLight3D

var min_energy = 0.2
var max_energy = 0.5

func _ready() -> void:
	assert(spot_light != null, "spot light must be assigned on poop bucket script")
	
	spot_light.light_energy = min_energy

func _on_click():
	print_debug("Clicked on poop bucket!")
	
func _on_drag(start_position: Vector2, current_position: Vector2, drag_distance: float):
	pass
	
func _on_drop(start_position: Vector2, end_position: Vector2, drag_distance: float):
	pass

func _on_hover():
	spot_light.light_energy = max_energy
	
func _on_hover_exit():
	spot_light.light_energy = min_energy
	
	
