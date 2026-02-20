extends StaticBody2D



func _ready() -> void:
	modulate = Color(Color.MEDIUM_PURPLE,0.7)

func _process(_delta):
	if Global.is_dragging:
		visible = true
	else:
		visible = false
