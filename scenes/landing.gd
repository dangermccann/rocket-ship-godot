extends Node3D

const LANDED_Y: float = 7.4
const START_Y: float = 31.0

const STATE_WAITING_BOOSTER = 0
const STATE_WAITING_LIGHTS = 1
const STATE_LANDING = 2
const STATE_LANDED = 3
const STATE_CRASHED = 4

const BASE_DESCEND = 1.0
const DESCEND_SPEED = 3.5
const GRAVITY = 3.5

const IMPACT_SCENE = preload("res://assets/effects/ImpactEffect.tscn")

@onready var ship = $"Ship Parent"
@onready var ship_control = $"Ship Parent/Space Ship Basic"
@onready var light_1 = $"Ship Parent/Light1"
@onready var light_2 = $"Ship Parent/Light2"

var ship_state 
var velocity

func _ready() -> void:
	ship.position.y = START_Y
	GlobalEvents.input_state_changed.connect(_on_input_state_changed)
	
	light_1.visible = false
	light_2.visible = false
	
	change_state(STATE_WAITING_BOOSTER)


func _process(delta: float) -> void:
	if ship_state == STATE_WAITING_BOOSTER:
		_descend(delta)
		
		velocity = velocity + delta * GRAVITY
		
		if ship.position.y <= LANDED_Y:
			change_state(STATE_CRASHED)
	
	if ship_state == STATE_LANDING:
		if Input.is_action_pressed("look_down") or ControlPanel.ControlInputs["JOYSTICK_DOWN"].is_active():
			velocity = DESCEND_SPEED
		elif Input.is_action_pressed("look_up") or ControlPanel.ControlInputs["JOYSTICK_UP"].is_active():
			velocity = -DESCEND_SPEED
		else: 
			velocity = 0.0
		
		_descend(delta)
		
		if ship.position.y <= LANDED_Y:
			change_state(STATE_LANDED)

func _descend(delta: float):
	ship.position.y -= BASE_DESCEND * velocity * delta

func _on_input_state_changed(full_id, state):
	if ship_state == STATE_WAITING_BOOSTER:
		if full_id == "BOOSTER_4" and state == ControlInput.PRESSED:
			change_state(STATE_WAITING_LIGHTS)
			#change_state(STATE_LANDING)
			return

	if ship_state == STATE_WAITING_LIGHTS:
		if full_id == "POWER" and state == ControlInput.ON:
		#if full_id == "BOOSTER_4" and state == ControlInput.PRESSED:
			change_state(STATE_LANDING)
			return
		

func change_state(new_state):
	ship_state = new_state
	
	if ship_state == STATE_WAITING_BOOSTER:
		velocity = 1.0
		ship_control.enable_boosters(false)
		
		Sounds.play_sound(Sounds.ENABLE_LANDING_BOOSTERS)
		return
		
	if ship_state == STATE_WAITING_LIGHTS:
		ship_control.enable_boosters(true)
		
		Sounds.play_sound(Sounds.TURN_ON_LANDING_LIGHTS)
		return
		
	if ship_state == STATE_LANDING:
		light_1.visible = true
		light_2.visible = true
		
		Sounds.play_sound(Sounds.LAND_ROCKET_SHIP)
		return
	
	if ship_state == STATE_LANDED:
		# TODO: Audio
		ship_control.enable_boosters(false)
	
	if ship_state == STATE_CRASHED:
		var impact: Node3D = IMPACT_SCENE.instantiate() 
		get_tree().root.add_child(impact)
		impact.call_deferred("set_particle_scale", 12)
		impact.global_position = ship.global_position
		
		ship.queue_free()
		
