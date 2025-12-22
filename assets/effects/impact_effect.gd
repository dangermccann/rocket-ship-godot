# ImpactEffect.gd
extends Node3D

@onready var cleanup_timer = $LifespanTimer
@onready var explosion_sound = $ExplosionSound
@onready var fire: GPUParticles3D = $FireParticles
@onready var smoke: GPUParticles3D = $SmokeParticles

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

func set_particle_scale(scale):
	var process_mat: ParticleProcessMaterial = fire.process_material
	process_mat.scale_min = 0.5 * scale
	process_mat.scale_max = 2.0 * scale
	
	process_mat = smoke.process_material
	process_mat.scale_min = 0.5 * scale
	process_mat.scale_max = 2.0 * scale
