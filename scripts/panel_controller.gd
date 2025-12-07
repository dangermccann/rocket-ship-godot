extends Node

const TIOLET_SOUND = preload("res://audio/Toilet.ogg")
const HIGH_DOWN_SOUND = preload("res://audio/highDown.ogg")
const HIGH_UP_SOUND = preload("res://audio/highUp.ogg")
const PEP_SOUND_1 = preload("res://audio/pepSound1.ogg")
const PEP_SOUND_2 = preload("res://audio/pepSound2.ogg")
const PEP_SOUND_3 = preload("res://audio/pepSound3.ogg")
const PEP_SOUND_4 = preload("res://audio/pepSound4.ogg")
const PEP_SOUND_5 = preload("res://audio/pepSound5.ogg")
const PHASER_UP_SOUND_1 = preload("res://audio/phaserUp1.ogg")
const PHASER_UP_SOUND_2 = preload("res://audio/phaserUp2.ogg")
const PHASER_UP_SOUND_3 = preload("res://audio/phaserUp3.ogg")
const TWO_TONE_SOUND_1 = preload("res://audio/twoTone1.ogg")
const TWO_TONE_SOUND_2 = preload("res://audio/twoTone2.ogg")


func _ready() -> void:
	GlobalEvents.input_state_changed.connect(_on_input_state_changed)

func _on_input_state_changed(id, state) -> void:
	var ctl: ControlInput = ControlPanel.find_control_input(id)
	
	if ctl.full_id.begins_with("BOOSTER") and state == ControlInput.PRESSED:
		GlobalEvents.emit_signal("booster_button", ctl.full_id)
	
	# Handle global sound effects and behaviors here 
	match ctl.full_id:
		"ALARM_OVERRIDE":
			play_sound(HIGH_DOWN_SOUND)
			ControlPanel.refresh_state()
		"POWER":
			play_sound(HIGH_UP_SOUND)
		"MODE":
			play_sound(PEP_SOUND_1)
		"LAMP":
			play_sound(PEP_SOUND_2)
		"ACK":
			play_sound(PEP_SOUND_3)
		"PYRO_0":
			play_sound(PHASER_UP_SOUND_1)
		"PYRO_1":
			play_sound(PHASER_UP_SOUND_1)
		"PYRO_2":
			play_sound(PHASER_UP_SOUND_1)
		"PYRO_3":
			play_sound(PHASER_UP_SOUND_1)
		"PYRO_4":
			play_sound(PHASER_UP_SOUND_1)
		"PYRO_5":
			play_sound(PHASER_UP_SOUND_1)
		"PYRO_6":
			play_sound(PHASER_UP_SOUND_1)
		"DOCKING":
			play_sound(PHASER_UP_SOUND_2)
			sync_led("CONTROL-0", state)
		"GLYCOL":
			play_sound(PEP_SOUND_4)
			sync_led("CONTROL-1", state)
		"SCE":
			play_sound(HIGH_DOWN_SOUND)
			sync_led("CONTROL-2", state)
		"WASTE":
			play_sound(TIOLET_SOUND)
			sync_led("CONTROL-3", state)
		"VERIFY":
			play_sound(PHASER_UP_SOUND_3)
		"BYPASS":
			play_sound(TWO_TONE_SOUND_1)
		"ARM":
			play_sound(TWO_TONE_SOUND_2)
			get_tree().change_scene_to_file("res://scenes/ui/password_ui.tscn")
			
		
func play_sound(sound: Resource):
	var player = AudioStreamPlayer.new()
	player.stream = sound
	get_tree().root.add_child(player)
	
	# max volume is 0 db
	player.volume_db = 0.0
	player.play()
	
	# Connect the signal that fires when the sound is finished
	# This automatically removes the temporary node to clean up memory.
	player.finished.connect(player.queue_free)

func sync_led(led_id, state):
	var led :Led = ControlPanel.Leds[led_id]
	if state == "ON":
		led.on()
	else:
		led.off()
