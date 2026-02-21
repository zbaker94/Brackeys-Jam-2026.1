extends Area3D

var poop_scene = preload("res://Scenes/poop.tscn")

@export var global_stats: GlobalStats

@export var poop_check_interval := 5.0

var poop_check_counter := 0.0

func _process(delta: float) -> void:
	check_spawn_poop(delta)


func check_spawn_poop(delta: float):
	poop_check_counter += delta
	
	if poop_check_counter >= poop_check_interval:
		print("time to check for poop!")
		poop_check_counter = 0
		var current_poop_count = get_tree().get_nodes_in_group("poop").size()
		print("Current poop count: ", current_poop_count)
		
		assert(global_stats != null, "poop spawner must have reference to global stats object")
		
		var hunger_stat = global_stats.find_stat_by_name("hunger")
		
		assert(hunger_stat != null, "global stats does not have 'hunger' stat needed for poop spawner")
		
		var max_hunger = hunger_stat.initial_value
		var current_hunger = hunger_stat._current_value
		
		var percentage_hungry = (current_hunger / max_hunger) * 100
		print("hunger percentage: " + str(percentage_hungry))
		
		var random_chance = randf_range(0, 100)
		print("ramdom roll: " + str(random_chance))
		
		if random_chance < percentage_hungry:
			print("I'm poopin")
			var pos: Vector3 = get_random_point()
			spawn_poop(pos)
	
	

func spawn_poop(location: Vector3):
	var poop_instance = poop_scene.instantiate()
	add_child(poop_instance)
	poop_instance.global_position = location
	
	if poop_instance is RigidBody3D:
		var impulse = Vector3(
			randf_range(-0.3, 0.3),  # Random lateral X force
			randf_range(1.0, 1.5),   # Upward force
			randf_range(-0.2, 0.2)   # Random lateral Z force
		)
		poop_instance.apply_central_impulse(impulse)

func get_random_point() -> Vector3:
	var collision_shape: CollisionShape3D = null
	for child in get_children():
		if child is CollisionShape3D:
			collision_shape = child
			break
	
	if not collision_shape or not collision_shape.shape:
		push_error("No collision shape found in Area3D")
	
	var shape = collision_shape.shape
	var random_point := Vector3.ZERO
	
	if shape is BoxShape3D:
		var box_shape: BoxShape3D = shape
		var extents = box_shape.size / 2.0
		random_point = Vector3(
			randf_range(-extents.x, extents.x),
			randf_range(-extents.y, extents.y),
			randf_range(-extents.z, extents.z)
		)
		print("Box size: ", box_shape.size)
		print("Random local point: ", random_point)
	else:
		push_error("Unsupported shape type: " + str(shape.get_class()))
	
	# Transform local point to global space
	var world_point = collision_shape.global_position + random_point
	print("Collision shape position: ", collision_shape.global_position)
	print("World point: ", world_point)
	return world_point
