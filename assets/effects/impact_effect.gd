# ImpactEffect.gd
extends Node3D

@onready var cleanup_timer = $LifespanTimer
@onready var explosion_sound = $ExplosionSound
@onready var fire = $FireParticles
@onready var smoke = $SmokeParticles

func _ready():
	# start particle systems
	fire.emitting = true
	smoke.emitting = true
	
	# Start the cleanup timer
	cleanup_timer.start()
	
	# Connect signal for self-cleanup
	cleanup_timer.timeout.connect(queue_free)
	
	# Ensure sound plays even if the body is paused
	explosion_sound.play()
	
