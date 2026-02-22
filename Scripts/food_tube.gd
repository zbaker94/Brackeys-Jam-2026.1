extends Interactable

@export var sprite: AnimatedSprite3D
@export var audio: AudioStreamPlayer3D

func _play_idle():
	sprite.animation = "idle"
	sprite.play()
	sprite.animation_finished.disconnect(_play_idle)

func _play_puke():
	sprite.animation = "puke"
	sprite.animation_finished.connect(_play_idle)
	
	audio.play()

func _on_click():
	print_debug("Clicked on food tube!")
	_play_puke()
	
func _on_drag(start_position: Vector2, current_position: Vector2, drag_distance: float):
	pass
	
func _on_drop(start_position: Vector2, end_position: Vector2, drag_distance: float):
	pass

func _on_hover():
	pass
	
func _on_hover_exit():
	pass
	
	
