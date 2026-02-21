@abstract

extends Node

class_name Interactable

@abstract
func _on_hover()

@abstract
func _on_hover_exit()

@abstract
func _on_click()

@abstract
func _on_drag(start_position: Vector2, current_position: Vector2, drag_distance: float)

@abstract
func _on_drop(start_position: Vector2, end_position: Vector2, drag_distance: float)
