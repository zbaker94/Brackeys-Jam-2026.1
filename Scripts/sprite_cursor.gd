extends AnimatedSprite2D

class_name SpriteCursor

enum CursorAnimation {
	POINT,
	GRAB,
	TAP
}

@export var default_animation: CursorAnimation = CursorAnimation.POINT

# Cursor size as a percentage of the smallest viewport dimension
@export var cursor_size_percent: float = 0.05  # 5% of viewport
@export var min_cursor_size: float = 16.0  # Minimum pixels
@export var max_cursor_size: float = 128.0  # Maximum pixels

# Hotspot offsets per animation (normalized 0-1, where 0.5,0.5 is center)
# Example: {"point": Vector2(0.2, 0.1), "grab": Vector2(0.5, 0.5)}
@export var animation_hotspots: Dictionary = {}
@export var default_hotspot: Vector2 = Vector2(0.5, 0.5)  # Center by default

var cached_viewport_size: Vector2 = Vector2.ZERO
var cached_frame: int = -1
var cached_animation: String = ""

var hovered_object: Interactable
var hovered_animation: CursorAnimation = CursorAnimation.POINT
var dragged_object: Interactable = null
var is_dragging: bool = false
var drag_start_position: Vector2 = Vector2.ZERO
var mouse_pressed: bool = false
@export var drag_threshold: float = 5.0  # Pixels to move before considering it a drag

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed == true: 
				print("Left mouse button pressed!")
				frame = 1
				mouse_pressed = true
				drag_start_position = event.position
				
			if event.is_released() == true: 
				print("Left mouse button released!")
				frame = 0
				mouse_pressed = false
				
				# Update animation based on hover state
				if hovered_object == null:
					animation = CursorAnimation.keys()[default_animation].to_lower()
				else:
					animation = CursorAnimation.keys()[hovered_animation].to_lower()
				
				# Handle drop or click
				if is_dragging and dragged_object != null:
					var drag_distance = event.position.distance_to(drag_start_position)
					dragged_object._on_drop(drag_start_position, event.position, drag_distance)
					dragged_object = null
				elif hovered_object != null:
					hovered_object._on_click()
				
				is_dragging = false
	
	# Detect drag motion
	if event is InputEventMouseMotion and mouse_pressed:
		if not is_dragging:
			var drag_distance = event.position.distance_to(drag_start_position)
			if drag_distance > drag_threshold:
				# Start dragging
				is_dragging = true
				if hovered_object != null:
					dragged_object = hovered_object
					dragged_object._on_drag(drag_start_position, event.position, drag_distance)

func _ready() -> void:
	update_cursor()

func _process(delta: float) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Only update cursor if viewport size, animation, or frame changed
	if viewport_size != cached_viewport_size or frame != cached_frame or animation != cached_animation:
		update_cursor()

func update_cursor() -> void:
	var image = sprite_frames.get_frame_texture(animation, frame)
	var cursor_type = Input.CURSOR_ARROW
	
	# Get viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	var smallest_dimension = min(viewport_size.x, viewport_size.y)
	
	# Calculate desired cursor size based on viewport
	var desired_size = smallest_dimension * cursor_size_percent
	
	# Clamp between min and max
	var final_size = clamp(desired_size, min_cursor_size, max_cursor_size)
	
	# Calculate scale factor
	var original_size = max(image.get_width(), image.get_height())
	var scale_factor = final_size / original_size
	
	# Create scaled image
	var scaled_image = Image.create(
		int(image.get_width() * scale_factor),
		int(image.get_height() * scale_factor),
		false,
		image.get_image().get_format()
	)
	scaled_image.copy_from(image.get_image())
	scaled_image.resize(
		int(image.get_width() * scale_factor),
		int(image.get_height() * scale_factor),
		Image.INTERPOLATE_LANCZOS
	)
	
	var scaled_texture = ImageTexture.create_from_image(scaled_image)
	
	# Get hotspot for current animation (normalized coordinates)
	var hotspot_normalized = animation_hotspots.get(animation, default_hotspot)
	var cursor_hotspot = Vector2(
		scaled_texture.get_width() * hotspot_normalized.x,
		scaled_texture.get_height() * hotspot_normalized.y
	)
	
	Input.set_custom_mouse_cursor(scaled_texture, cursor_type, cursor_hotspot)
	
	# Cache current values
	cached_viewport_size = viewport_size
	cached_frame = frame
	cached_animation = animation

func entered(anim: CursorAnimation, node_entered: Interactable, do_not_change_animation: bool) -> void:
	hovered_animation = anim
	if !do_not_change_animation and !mouse_pressed:
		animation = CursorAnimation.keys()[anim].to_lower()
	node_entered._on_hover()
	hovered_object = node_entered

func exited(anim: CursorAnimation, node_exited: Interactable, do_not_change_animation: bool) -> void:
	if !do_not_change_animation and !mouse_pressed:
		animation = CursorAnimation.keys()[default_animation].to_lower()
	node_exited._on_hover_exit()
	
	# Only clear hovered_object if it matches the exiting node
	if hovered_object == node_exited:
		hovered_object = null
