extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Rotate the cube around its Y-axis (vertical axis)
	# The 'rotation_degrees' property works in degrees, making it intuitive.
	# Adjust 50.0 to change the speed.
	rotation_degrees.y += 50.0 * delta
