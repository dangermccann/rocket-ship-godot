extends Node3D # Use this if you chose a standard Node3D

signal ship_destroyed

# Configuration variables
const BASE_THRUST = 1.2 # Base speed of the ship
const BOOSTER_THRUST = 60.0
const ACCELERATION_RATE = 5.0 # How quickly the ship reaches max speed (for smoothing)

const STATE_FLYING = 0
const STATE_WARPING = 1
const STATE_ROLLING = 2
const STATE_DESTROYED = 3

const MAX_WARP_SPEED = 1000.0 # Very fast speed for warping
const ROTATION_STRENGTH = 4.0 # How quickly the ship turns
const SLOWDOWN_DISTANCE = 500.0 # Distance to begin slowing down
const STOP_DISTANCE = 400.0 # Distance to stop warp and transition back to flying

const LASER_BEAM_SCENE = preload("res://assets/effects/LaserBeam.tscn")
const IMPACT_SCENE = preload("res://assets/effects/ImpactEffect.tscn")

const BASE_FOV = 75.0
const BOOST_FOV = 85.0
const FOV_LERP_SPEED = 4.0

@onready var camera_node = $Camera3D 
@onready var mesh = $Camera3D/SpaceShipMesh
@onready var boosters_node = $Camera3D/SpaceShipMesh/Boosters
@onready var audio_player = $AudioPlayer
@onready var laser_spawner = $Camera3D/SpaceShipMesh/LaserSpawner
@onready var laser_ray = $Camera3D/SpaceShipMesh/LaserSpawner/LaserRay
@onready var boost_particals = $Camera3D/BoostParticals

var booster_cooldown = 0

var current_state = STATE_FLYING
var target_planet_location = Vector3.ZERO
var current_thrust_speed = BASE_THRUST
var current_planet

var roll_timer = 0.0
var roll_direction = 1.0 # 1.0 for right roll, -1.0 for left roll
var initial_roll_z = 0.0 # Starting Z-rotation


func _ready():
	# Connect this script's handler function to the global signal
	GlobalEvents.booster_button.connect(_on_booster_button)
	GlobalEvents.warp_to.connect(_on_warp_to)
	GlobalEvents.joystick_input_event.connect(_on_joystick_event)
	
	audio_player.volume_db = 0
	
func _process(delta):
	var velocity = Vector3.ZERO
	var target_fov = BASE_FOV

	# Det the direction the camera is looking
	# The 'global_transform.basis.z' vector is the camera's Z-axis.
	# The NEGATIVE Z-axis is the direction the camera is facing (forward).
	var desired_direction = -camera_node.global_transform.basis.z
	
	if current_state == STATE_FLYING:
		# Make the booster visuals appear while active
		if(booster_cooldown > 0):
			booster_cooldown -= delta
			
			enable_boosters(true)
			boost_particals.emitting = true
			
			current_thrust_speed = BOOSTER_THRUST
			target_fov = BOOST_FOV
			
		else:
			enable_boosters(false)
			boost_particals.emitting = false
			
			current_thrust_speed = BASE_THRUST
		
	elif current_state == STATE_WARPING:
		enable_boosters(true)
		boost_particals.emitting = true
		
		target_fov = BOOST_FOV
		
		# 1. Calculate direction and distance
		var direction_to_target = target_planet_location - global_position
		var distance = direction_to_target.length()
		desired_direction = direction_to_target.normalized()
		
		# 2. Handle Rotation (Gradual Turn)
		# Use LookAt to find the required rotation, then interpolate to smoothly turn the ship.
		var look_at_basis = camera_node.global_transform.looking_at(target_planet_location, Vector3.UP).basis
		camera_node.global_transform.basis = camera_node.global_transform.basis.slerp(look_at_basis, ROTATION_STRENGTH * delta)
		
		# 3. Handle Speed and State Transition
		if distance < SLOWDOWN_DISTANCE:
			# Gradually reduce speed as we approach
			current_thrust_speed = lerp(current_thrust_speed, BASE_THRUST, delta)
			
			if distance < STOP_DISTANCE:
				# Transition back to flying state
				current_state = STATE_FLYING
				current_thrust_speed = BASE_THRUST
				velocity = Vector3.ZERO
				
				booster_cooldown = 0
				enable_boosters(false)
				boost_particals.emitting = false
				
				audio_player.stop()
				GlobalEvents.emit_signal("arrived_at_planet", current_planet)
				print("Warp complete. Arrived at ", current_planet)
				return # Exit early to prevent further movement this frame
		
		else:
			# Accelerate up to max warp speed
			current_thrust_speed = lerp(current_thrust_speed, MAX_WARP_SPEED, delta * ACCELERATION_RATE)
	
	# --- Barrel Roll Logic ---
	elif current_state == STATE_ROLLING:
		
		# 1. Increment the timer
		roll_timer += delta
		
		# 2. Calculate the rotation progress
		var progress = min(roll_timer / 0.5, 1.0) # Ensures progress never exceeds 1.0
		
		# 3. Calculate the new Z-rotation (Roll)
		var total_rotation = deg_to_rad(360.0 * roll_direction)
		
		# Use interpolation (ease out/in) for a smoother start/stop feel
		var eased_progress = ease(progress, -2.0) # Adjust the easing curve (2.0 is Quadratic)

		# Calculate the target Z-rotation for this frame
		var new_roll_z = initial_roll_z + (total_rotation * eased_progress)
		
		# Apply the new Z-rotation (Roll)
		mesh.rotation.z = new_roll_z
		
		# Maintain forward direction during the roll (uses the ship's current forward)
		desired_direction = -global_transform.basis.z 
		current_thrust_speed = BASE_THRUST # Maintain base speed during the roll

		# 4. Check for Completion
		if progress >= 1.0:
			current_state = STATE_FLYING
			
			# Reset the rotation.z to a clean value (0 to 360 equivalent)
			mesh.rotation.z = initial_roll_z + deg_to_rad(360.0 * roll_direction)
			mesh.rotation.z = wrapf(rotation.z, -PI, PI) # Keep the angle within Godot's rotation range (-180 to 180 deg)
			
			# Re-enable player control visuals
			# Example: $Camera.can_rotate = true
			
	elif current_state == STATE_DESTROYED:
		current_thrust_speed = 0.0
		boost_particals.emitting = false
	
	# Set camera field-of-view based on speed / state
	camera_node.fov = lerp(camera_node.fov, target_fov, delta * FOV_LERP_SPEED)
	
	# Apply movement based on the current direction and speed
	var desired_velocity = desired_direction * current_thrust_speed
	velocity = velocity.lerp(desired_velocity, delta * ACCELERATION_RATE)
	
	translate(desired_direction * BASE_THRUST * current_thrust_speed * delta)

func enable_boosters(on: bool):
	var led = ControlPanel.Leds[ControlPanel.THRUST]
	if on:
		boosters_node.visible = true
		led.on()
	else:
		boosters_node.visible = false
		led.off()

func _on_booster_button(button):
	if button == "BOOSTER_0":
		booster_cooldown = 8 
		boost_audio()
	
	if button == "BOOSTER_1":
		if current_state == STATE_FLYING:
			GlobalState.modal_ui(GlobalState.UI_STATE_WARP)
			
	if button == "BOOSTER_2":
		if current_planet != null:
			if MissionManager.last_mission_outcome == MissionManager.MISSION_SUCCESS:
				get_tree().change_scene_to_file("res://scenes/landing.tscn")
		

func _on_warp_to(planet):
	current_planet = planet
	
	var node: Node3D = get_tree().root.get_node("/root/Space/Planets/" + planet)
	
	# Assume MeshInstance3D is first child of planet scene
	# TODO: Planets should be a scene that lets me get this reference properly 
	var aabb = get_world_aabb(node.get_child(0).get_child(0))
	var radius = aabb.size.z / 2.0
	var dir_vector = (node.position - global_position).normalized()
	var adjustment = Vector3(-(dir_vector * radius).x, radius / 2.0, -(dir_vector * radius).z)
	
	target_planet_location = node.position + adjustment
	current_state = STATE_WARPING
	print("Initiating warp to: ", target_planet_location)
	audio_player.stream = Sounds.WARP_SOUND
	audio_player.play()

func _on_joystick_event(input_action, state):
	if input_action == "joystick_trigger_front" and state:
		fire_laser()
		
	if input_action == "joystick_trigger_top" and state:
		var dir = 0
		
		if ControlPanel.ControlInputs["JOYSTICK_RIGHT"].is_active() or Input.is_action_pressed("look_right"):
			dir = 1
		elif ControlPanel.ControlInputs["JOYSTICK_LEFT"].is_active() or Input.is_action_pressed("look_left"):
			dir = -1
			
		if dir != 0:
			do_barrel_roll(dir)

func boost_audio():
	audio_player.stream = Sounds.BOOST_SOUND
	audio_player.play()
	

	
# Function to be called when the trigger button is pressed
func fire_laser():
	# 1. Force a RayCast update to get the hit result this frame
	laser_ray.force_raycast_update()
	
	var start_point = laser_spawner.global_position
	var end_point = laser_spawner.global_position + (laser_spawner.global_transform.basis.z * laser_ray.target_position.length())
	var hit_target = false
	var hit_collision: RigidBody3D = null

	if laser_ray.is_colliding():
		hit_target = true
		hit_collision = laser_ray.get_collider() as RigidBody3D
		end_point = laser_ray.get_collision_point() # Set end to the collision point

	# 2. Spawn Visual Beam and Hit Effect
	_spawn_visual_beam(start_point, end_point, hit_target)
	
	if hit_target and hit_collision.is_in_group("Astroids"):
		_apply_damage_and_impact(hit_collision, end_point)
		MissionManager.log_event(MissionManager.REMOVAL_EVENT, { "type": "Astroid", "quantity": "1" })
		
	Sounds.play_sound(Sounds.LASER_SOUND)


func _spawn_visual_beam(start_pos: Vector3, end_pos: Vector3, hit: bool):
	var beam: Node3D = LASER_BEAM_SCENE.instantiate()
	get_tree().root.add_child(beam)
	
	# Position the beam's root at the start point
	beam.global_position = start_pos
	
	# Calculate the length and direction
	var length = start_pos.distance_to(end_pos)
	
	# Point the beam towards the target (or the end of range)
	beam.look_at(end_pos, Vector3.UP, false)
	
	# Scale the mesh to match the calculated length
	# Note: This assumes your LaserBeam scene has a mesh scaled to 1 unit initially.
	beam.scale.z = length 

func _apply_damage_and_impact(target_node, impact_pos: Vector3):
	# 1. Apply Damage (If the target has a damage function)
	if target_node.has_method("take_damage"):
		target_node.take_damage()
		
	# 2. Spawn Impact Effect 
	var impact = IMPACT_SCENE.instantiate() 
	get_tree().root.add_child(impact)
	impact.global_position = impact_pos # Spawn it at the collision point

func do_barrel_roll(direction: float):
	# Only start a roll if currently flying
	if current_state != STATE_FLYING:
		return
		
	roll_direction = direction # -1 for left roll, 1 for right roll
	current_state = STATE_ROLLING
	roll_timer = 0.0
	
	# Store the ship's current Z-rotation so we can roll relative to it
	initial_roll_z = rotation.z 
	
	Sounds.play_sound(Sounds.BARREL_ROLL_SOUND)
	
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	# Don't die from collision when warping or barrel rolling
	if current_state == STATE_WARPING or current_state == STATE_ROLLING:
		return
	
	if body.is_in_group("Astroids"):
		collision_death()
		
	elif body.is_in_group("IceChunks"):
		MissionManager.log_event(MissionManager.COLLECTION_EVENT, { "type": "Ice Chunk", "quantity": "1" })
		# TODO: Figure out how to not assume it's the parent node in the tree
		body.get_parent_node_3d().queue_free() 
		
		# TODO: Play some animation / particle effect
		Sounds.play_sound(Sounds.COLLECT_SOUND)


func _on_area_3d_area_entered(area: Area3D) -> void:
	if current_state == STATE_WARPING or current_state == STATE_ROLLING:
		return
		
	if area.is_in_group("Planets"):
		collision_death()
	
func collision_death():
	var impact = IMPACT_SCENE.instantiate() 
	get_tree().root.add_child(impact)
	impact.global_position = mesh.global_position + Vector3(0, 0, -1)
	
	mesh.visible = false
	current_state = STATE_DESTROYED
	audio_player.stop()
	ship_destroyed.emit()

# TODO: move this to a utility class?
func get_world_aabb(mesh_instance_node: MeshInstance3D) -> AABB:
	
	# 1. Get the Mesh Resource
	var this_mesh = mesh_instance_node.mesh
	if this_mesh == null:
		print("Error: MeshInstance3D does not have a mesh resource assigned.")
		return AABB() # Return an empty AABB on error

	# 2. Get the Local Bounding Box (AABB)
	# This AABB is defined in the local space of the MeshInstance3D node.
	var local_aabb: AABB = this_mesh.get_aabb()

	# 3. Get the Global Transform
	# This includes the node's position, rotation, and scale in the world.
	var g_transform = mesh_instance_node.global_transform

	# 4. Transform the AABB to World Coordinates	
	var world_aabb = g_transform * local_aabb
	
	return world_aabb
