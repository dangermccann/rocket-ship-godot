# LaserBeam.gd
extends Node3D

@onready var lifespan_timer = $LifespanTimer

# Called when the scene is added to the world and configured by the RocketShip
func _ready():
	# Start the timer immediately when the beam is created
	lifespan_timer.start()
	
	# Connect the timeout signal to the self-destruct function
	lifespan_timer.timeout.connect(_on_lifespan_timer_timeout)

# This function is called automatically when the timer finishes
func _on_lifespan_timer_timeout():
	# Remove the node from the scene tree and free its memory
	queue_free()
