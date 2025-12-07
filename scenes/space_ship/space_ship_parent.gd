extends Node3D # Use this if you chose a standard Node3D

# Configuration variables
const BASE_THRUST = 1.0 # Base speed of the ship
const ACCELERATION_RATE = 5.0 # How quickly the ship reaches max speed (for smoothing)

const STATE_FLYING = 0
const STATE_WARPING = 1

const MAX_WARP_SPEED = 1000.0 # Very fast speed for warping
const ROTATION_STRENGTH = 4.0 # How quickly the ship turns
const SLOWDOWN_DISTANCE = 500.0 # Distance to begin slowing down
const STOP_DISTANCE = 400.0 # Distance to stop warp and transition back to flying

const EXPLOSION_SOUND = preload("res://audio/booster_1.wav")
const WARP_SOUND = preload("res://audio/spaceEngine_000.ogg")


@onready var camera_node = $Camera3D # Get the Camera node reference
@onready var boosters_node = $Camera3D/SpaceShipMesh/Boosters
@onready var audio_player = $AudioPlayer

var booster_cooldown = 0
var booster_thrust = 0

var current_state = STATE_FLYING
var target_planet_location = Vector3.ZERO
var current_thrust_speed = BASE_THRUST

func _ready():
	# Connect this script's handler function to the global signal
	GlobalEvents.booster_button.connect(_on_booster_button)
	GlobalEvents.warp_to.connect(_on_warp_to)
	
	audio_player.volume_db = 0
	
func _process(delta):
	var velocity = Vector3.ZERO

	# Det the direction the camera is looking
	# The 'global_transform.basis.z' vector is the camera's Z-axis.
	# The NEGATIVE Z-axis is the direction the camera is facing (forward).
	var desired_direction = -camera_node.global_transform.basis.z
	
	if current_state == STATE_FLYING:
		# Make the booster visuals appear while active
		if(booster_cooldown > 0):
			booster_cooldown -= delta
			boosters_node.visible = true
			current_thrust_speed = booster_thrust
		else:
			boosters_node.visible = false
			
		current_thrust_speed = BASE_THRUST
			
	elif current_state == STATE_WARPING:
		boosters_node.visible = true
		
		# 1. Calculate direction and distance
		var direction_to_target = target_planet_location - global_position
		var distance = direction_to_target.length()
		desired_direction = direction_to_target.normalized()
		
		# 2. Handle Rotation (Gradual Turn)
		# Use LookAt to find the required rotation, then interpolate to smoothly turn the ship.
		var look_at_basis = camera_node.global_transform.looking_at(target_planet_location, Vector3.UP).basis
		var look_at_rotation = look_at_basis.get_rotation_quaternion()
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
				print("Warp complete. Entering stable orbit.")
				boosters_node.visible = false
				audio_player.stop()
				return # Exit early to prevent further movement this frame
		
		else:
			# Accelerate up to max warp speed
			current_thrust_speed = lerp(current_thrust_speed, MAX_WARP_SPEED, delta * ACCELERATION_RATE)
			
	# Apply movement based on the current direction and speed
	var desired_velocity = desired_direction * current_thrust_speed
	velocity = velocity.lerp(desired_velocity, delta * ACCELERATION_RATE)
	
	translate(desired_direction * BASE_THRUST * current_thrust_speed * delta)

func _on_booster_button(button):
	if button == "BOOSTER_0":
		booster_cooldown = 8 # TODO: assign varying durations based on the type of booster
		booster_thrust = 75
		boost_audio()
	
	if button == "BOOSTER_1":
		if current_state == STATE_FLYING:
			GlobalState.modal_ui(GlobalState.UI_STATE_WARP)

func _on_warp_to(planet):
	var node: Node3D = get_tree().root.get_node("/root/Main3D/Planets/" + planet)
	
	target_planet_location = node.position
	current_state = STATE_WARPING
	print("Initiating warp to: ", target_planet_location)
	audio_player.stream = WARP_SOUND
	audio_player.play()

func boost_audio():
	audio_player.stream = EXPLOSION_SOUND
	audio_player.play()
	
func play_sound(sound: Resource):
	# Create a new 3D player node
	var player = AudioStreamPlayer.new()
	
	# Set the sound stream
	player.stream = sound
	
	# Add the player to the scene tree
	get_tree().root.add_child(player)
	
	# max volume is 0 db
	player.volume_db = 0.0
	
	# Start playback
	player.play()
	
	# Connect the signal that fires when the sound is finished
	# This automatically removes the temporary node to clean up memory.
	player.finished.connect(player.queue_free)
