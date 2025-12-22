extends Node

func _ready() -> void:
	GlobalEvents.input_state_changed.connect(_on_input_state_changed)
	GlobalEvents.keypad_event.connect(_on_keypad_event)

func _on_input_state_changed(full_id, state) -> void:
	var ctl: ControlInput = ControlPanel.ControlInputs[full_id]
	
	if ctl.full_id.begins_with("BOOSTER") and state == ControlInput.PRESSED:
		GlobalEvents.emit_signal("booster_button", ctl.full_id)
	
	# Handle global sound effects and behaviors here 
	match ctl.full_id:
		"ALARM_OVERRIDE":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.HIGH_DOWN_SOUND)
		"POWER":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.HIGH_UP_SOUND)
		"MODE":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PEP_SOUND_1)
		"LAMP":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PEP_SOUND_2)
		"ACK":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PEP_SOUND_3)
		"PYRO_0":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PHASER_UP_SOUND_1)
		"PYRO_1":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PHASER_UP_SOUND_1)
		"PYRO_2":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PHASER_UP_SOUND_1)
		"PYRO_3":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PHASER_UP_SOUND_1)
		"PYRO_4":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PHASER_UP_SOUND_1)
		"PYRO_5":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PHASER_UP_SOUND_1)
		"PYRO_6":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PHASER_UP_SOUND_1)
		"DOCKING":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PHASER_UP_SOUND_2)
			sync_led("CONTROL-0", state)
		"GLYCOL":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.PEP_SOUND_4)
			sync_led("CONTROL-1", state)
		"SCE":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.HIGH_DOWN_SOUND)
			sync_led("CONTROL-2", state)
		"WASTE":
			if state == ControlInput.ON:
				Sounds.play_sound(Sounds.TIOLET_SOUND)
			sync_led("CONTROL-3", state)
		"VERIFY":
			Sounds.play_sound(Sounds.PHASER_UP_SOUND_3)
		"BYPASS":
			Sounds.play_sound(Sounds.TWO_TONE_SOUND_1)
		"ARM":
			Sounds.play_sound(Sounds.TWO_TONE_SOUND_2)
			get_tree().change_scene_to_file("res://scenes/ui/password_ui.tscn")

func _on_keypad_event(event):
	Sounds.play_sound(Sounds.KEY_SOUND)

func sync_led(led_id, state):
	var led :Led = ControlPanel.Leds[led_id]
	if state == "ON":
		led.on()
	else:
		led.off()
