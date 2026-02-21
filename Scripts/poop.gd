class_name Poop

extends RigidBody3D

# Preload scene once to avoid repeated load() calls
const POOP_SCENE = preload("res://Scenes/poop.tscn")

@export var attraction_radius: float = 3.0
@export var attraction_strength: float = 1.5
@export var min_distance: float = 0.3
@export var squish_variation: float = 0.3
@export var scale_variation: float = 0.2
@export var max_merges: int = 3

var is_merging: bool = false
var merge_count: int = 0
var mesh_instance: MeshInstance3D = null

func _ready() -> void:
	add_to_group("poop")
	
	mesh_instance = get_node_or_null("MeshInstance3D")
	
	# Apply random non-uniform scale variation to mesh only (deform based on initial 0.08 scale)
	if mesh_instance:
		var base_scale = 0.08
		var random_scale = Vector3(
			base_scale * (1.0 + randf_range(-scale_variation, scale_variation)),
			base_scale * (1.0 + randf_range(-scale_variation, scale_variation)),
			base_scale * (1.0 + randf_range(-scale_variation, scale_variation))
		)
		mesh_instance.scale = random_scale
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.5
	timer.one_shot = true
	timer.start()
	
	timer.timeout.connect(func():
		sleeping = true	
		timer.queue_free()
	)


func _physics_process(_delta: float) -> void:
	if is_merging:
		return
	
	var nearby_poops = get_tree().get_nodes_in_group("poop")
	var poops_to_merge: Array[Poop] = []
	
	# Check for poops within min_distance that should merge
	for poop in nearby_poops:
		if poop == self or poop.is_merging or poop.merge_count >= poop.max_merges:
			continue
		
		var distance = global_position.distance_to(poop.global_position)
		
		if distance <= min_distance:
			if poops_to_merge.is_empty():
				poops_to_merge.append(self)
			poops_to_merge.append(poop)
	
	# If we found poops to merge, handle the merge
	if poops_to_merge.size() >= 3:
		_merge_poops(poops_to_merge)
		return
	
	# Otherwise, apply attraction forces
	for poop in nearby_poops:
		if poop == self or poop.is_merging:
			continue
			
		if poop.merge_count >= poop.max_merges:
			continue
		
		var distance = global_position.distance_to(poop.global_position)
		
		if distance < attraction_radius and distance > min_distance:
			var direction = (poop.global_position - global_position).normalized()
			var force_magnitude = attraction_strength / distance
			apply_central_force(direction * force_magnitude)

func _merge_poops(poops: Array[Poop]) -> void:
	# Mark all as merging to prevent double-processing
	for poop in poops:
		poop.is_merging = true
	
	# Calculate average position, scale, and track highest merge count
	var avg_position = Vector3.ZERO
	var largest_poop_scale = Vector3.ZERO
	var cumulative_mass = 0
	var highest_merge_count = 0
	
	for poop in poops:
		avg_position += poop.global_position
		cumulative_mass += poop.mass
		
		if poop.scale.x > largest_poop_scale.x:
			largest_poop_scale = poop.scale
		
		if poop.merge_count > highest_merge_count:
			highest_merge_count = poop.merge_count
	
	avg_position /= poops.size()

	
	# Create new merged poop using preloaded scene
	var new_poop = POOP_SCENE.instantiate() as Poop
	get_parent().add_child(new_poop)
	new_poop.global_position = avg_position
	# Use uniform RigidBody3D scaling for merged poops (safe for Jolt Physics)
	new_poop.scale = largest_poop_scale + Vector3(0.6, 0.6, 0.6)
	if cumulative_mass > 2.5:
		cumulative_mass = 2.5
	new_poop.mass = cumulative_mass
	new_poop.merge_count = highest_merge_count + 1
	
	new_poop.apply_central_impulse(Vector3.UP * 4.0)
	
	# Delete old poops
	for poop in poops:
		poop.queue_free()
