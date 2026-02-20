extends Area3D

@export var animation: String = "tap"

@export var cursor_proxy: SpriteCursor 


var parent_interactable: Interactable


func _ready() -> void:
	# Try to find cursor_proxy at root if not set
	if cursor_proxy == null:
		var scene_root = get_tree().current_scene
		if scene_root:
			var cursor_node = scene_root.get_node_or_null("CursorProxy")
			if cursor_node and cursor_node is SpriteCursor:
				cursor_proxy = cursor_node
	
	assert(cursor_proxy != null, "Must set cursor_proxy on Mouse Collider object or have a CursorProxy node at root")
	
	var parent_node_3d = get_parent_node_3d()
	
	assert(parent_node_3d is Interactable, "Parent of mouse collider must be of type Interactable")
	
	parent_interactable = parent_node_3d
	
	# Connect signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	cursor_proxy.entered(animation, parent_interactable)

func _on_mouse_exited() -> void:
	cursor_proxy.exited(animation, parent_interactable)
