extends Control

@onready var line_edit = $Panel/LineEdit
@onready var lock_image = $Panel/Lock
@onready var audio = $AudioStreamPlayer

var entered = ""
var unlock_cooldown = 0
var unlock_cooldown_running = false

const PWD = "1353"
const LOCK_RES   = preload("res://ui/images/locked.png")
const UNLOCK_RES = preload("res://ui/images/unlocked.png")

const KEY_SOUND = preload("res://audio/tone1.ogg")
const ERROR_SOUND = preload("res://audio/phaserDown3.ogg")
const SUCCESS_SOUND = preload("res://audio/powerUp7.ogg")

const MAIN_SCENE: String = "res://scenes/main_3d.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalEvents.keypad_event.connect(_on_keypad_event)
	audio.volume_db = 0.0
	var timer = get_tree().create_timer(1)
	timer.timeout.connect(_on_timeout)
	reset()
	
func _on_timeout():
	unlock_led()
	
func _enter_tree():
	unlock_led()

func _process(delta):
	if unlock_cooldown_running:
		if(unlock_cooldown > 0):
			unlock_cooldown -= delta
		else:
			# countdown complete
			reset()
			get_tree().change_scene_to_file(MAIN_SCENE)
	

func _on_keypad_event(key_id):
	if unlock_cooldown_running:
		return
		
	entered = entered + key_id
	line_edit.text = line_edit.text + "*"
	
	if entered == PWD:
		success()
	else:
		if entered.length() >= 4:
			entered = ""
			line_edit.text = ""
			
			audio.stream = ERROR_SOUND
			audio.play()
			
		else:
			audio.stream = KEY_SOUND
			audio.play()

func lock_led():
	ControlPanel.Leds["SECURITY-0"].off()
	ControlPanel.Leds["SECURITY-1"].on()

func unlock_led():
	ControlPanel.Leds["SECURITY-0"].on()
	ControlPanel.Leds["SECURITY-1"].off()
	
func success():
	unlock_cooldown_running = true
	unlock_cooldown = 2
	lock_image.texture = UNLOCK_RES
	
	audio.stream = SUCCESS_SOUND
	audio.play()
	
	lock_led()

func reset():
	unlock_cooldown_running = false
	unlock_cooldown = 0
	lock_image.texture = LOCK_RES
	entered = ""
	line_edit.text = ""
