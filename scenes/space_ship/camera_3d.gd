extends Camera3D # Or 'Camera' in older Godot 3.x versions

# Configuration variables
const ROTATION_SPEED = 20.0  # Speed of rotation in degrees per frame
const MAX_PITCH_ANGLE = 75.0 # Limit how far up/down the pilot can look (75 degrees)
const MAX_ROLL_ANGLE = 10.0 # Max roll angle for the mesh (e.g., 5 degrees)
const MAX_MESH_PITCH_ANGLE  = 10.0 # Max pitch angle for the mesh (e.g., 5 degrees)

var target_mesh_roll = 0.0 # The desired Z-axis rotation for the mesh
var target_mesh_pitch = 0.0 # The desired X-axis rotation for the mesh

@onready var ship_mesh = $SpaceShipMesh

func _process(delta):
	var rotation_velocity = Vector2.ZERO

	
	# 1. Yaw (Left/Right look, Y-axis)
	if Input.is_action_pressed("look_right") or ControlPanel.ControlInputs["JOYSTICK_RIGHT"].is_active():
		rotation_velocity.x -= ROTATION_SPEED
	if Input.is_action_pressed("look_left") or ControlPanel.ControlInputs["JOYSTICK_LEFT"].is_active():
		rotation_velocity.x += ROTATION_SPEED
		
	# 2. Pitch (Up/Down look, X-axis)
	if Input.is_action_pressed("look_down") or ControlPanel.ControlInputs["JOYSTICK_DOWN"].is_active():
		rotation_velocity.y += ROTATION_SPEED
	if Input.is_action_pressed("look_up") or ControlPanel.ControlInputs["JOYSTICK_UP"].is_active():
		rotation_velocity.y -= ROTATION_SPEED
		
	# Apply Y-axis rotation (Yaw) directly to the parent's Y-axis (global rotation)
	# OR: Apply to the camera's local Y-axis if you want independent spinning.
	# For a typical space cockpit view, we rotate around the camera's local Y.
	rotate_y(deg_to_rad(rotation_velocity.x * delta))
	
	# Apply X-axis rotation (Pitch)
	# The X rotation is applied to the local axis, which controls the up/down tilt.
	var pitch_change = deg_to_rad(rotation_velocity.y * delta)
	rotate_object_local(Vector3.RIGHT, pitch_change)
	
	# Clamp Pitch Rotation (Prevent the camera from looking backward/flipping)
	# This keeps the look within the defined limits (e.g., +/- 75 degrees)
	var current_pitch = rad_to_deg(rotation.x)
	
	# Ensure rotation.x stays within the limit by resetting it if it goes too far.
	if current_pitch > MAX_PITCH_ANGLE:
		rotation.x = deg_to_rad(MAX_PITCH_ANGLE)
	elif current_pitch < -MAX_PITCH_ANGLE:
		rotation.x = deg_to_rad(-MAX_PITCH_ANGLE)
		
	# --- 3. Apply Mesh Roll Based on Yaw Input ---
	# Define the desired roll angle based on yaw input intensity
	if rotation_velocity.x != 0:
		# If rotating right (positive X velocity), target negative roll (tilts right)
		# If rotating left (negative X velocity), target positive roll (tilts left)
		target_mesh_roll = -MAX_ROLL_ANGLE * sign(rotation_velocity.x)
	else:
		# If no yaw input, gradually return to zero roll
		target_mesh_roll = 0.0

	# Smoothly move the RocketMesh's Z-axis rotation (roll) towards the target angle
	var current_roll_degrees = rad_to_deg(ship_mesh.rotation.z)
	
	current_roll_degrees = lerp(current_roll_degrees, target_mesh_roll, delta * 5.0)
	
	# Apply the smoothed rotation back to the mesh
	ship_mesh.rotation.z = deg_to_rad(current_roll_degrees)
	
	# --- 4. Apply Mesh Pitch Based on Pitch Input ---
	# Define the desired roll angle based on yaw input intensity
	if rotation_velocity.y != 0:
		# If rotating right (positive X velocity), target negative roll (tilts right)
		# If rotating left (negative X velocity), target positive roll (tilts left)
		target_mesh_pitch = -MAX_ROLL_ANGLE * sign(rotation_velocity.y)
	else:
		# If no yaw input, gradually return to zero roll
		target_mesh_pitch = 0.0

	# Smoothly move the RocketMesh's Z-axis rotation (roll) towards the target angle
	var current_pitch_degrees = rad_to_deg(ship_mesh.rotation.x)
	
	current_pitch_degrees = lerp(current_pitch_degrees, target_mesh_pitch, delta * 5.0)
	
	# Apply the smoothed rotation back to the mesh
	ship_mesh.rotation.x = deg_to_rad(current_pitch_degrees)
	
