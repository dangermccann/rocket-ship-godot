# GlobalEvents.gd
extends Node

# Signal emitted when serial data arrives, carrying the clean text string
signal serial_data_received(data_string)

# Signal emitted when serial data should be sent
signal serial_message(message)

# Signal emitted for joystick button/direction events
signal joystick_input_event(input_action, state)

# Signal emitted when a keypad button is pressed
signal keypad_event(key_id)

# Signal emitted when an input control changes state
signal input_state_changed(full_id, state)

# Signal emitted to simulate a control input using a key
signal simulated_control_input(full_id, state)

# Signal emitted when an input control changes state
signal booster_button(button)

signal ui_modal_closed()

signal warp_to(planet)

func _unhandled_key_input(event: InputEvent):
	if event is not InputEventKey:
		return
	if event.echo:
		return
	
	var key: Key = event.keycode
	var shift: bool = event.shift_pressed
	
	var input_id: String = ""
	var type = "INPUT"
	
	if shift:
		match key:
			Key.KEY_0: input_id = "BOOSTER_0"
			Key.KEY_1: input_id = "BOOSTER_1"
			Key.KEY_2: input_id = "BOOSTER_2"
			Key.KEY_3: input_id = "BOOSTER_3"
			Key.KEY_4: input_id = "BOOSTER_4"
			Key.KEY_5: input_id = "BOOSTER_5"
			Key.KEY_6: input_id = "BOOSTER_6"
			Key.KEY_7: input_id = "BOOSTER_7"
			Key.KEY_8: input_id = "BOOSTER_8"
			
			Key.KEY_Z: input_id = "ALARM_OVERRIDE"
			Key.KEY_X: input_id = "POWER"
			Key.KEY_C: input_id = "MODE"
			Key.KEY_V: input_id = "LAMP"
			Key.KEY_B: input_id = "ACK"
			
			Key.KEY_9: input_id = "JOYSTICK_TF"
			Key.KEY_P: input_id = "JOYSTICK_TT"
	else:
		type = "KEYPAD"
		match key:
			Key.KEY_0: input_id = "0"
			Key.KEY_1: input_id = "1"
			Key.KEY_2: input_id = "2"
			Key.KEY_3: input_id = "3"
			Key.KEY_4: input_id = "4"
			Key.KEY_5: input_id = "5"
			Key.KEY_6: input_id = "6"
			Key.KEY_7: input_id = "7"
			Key.KEY_8: input_id = "8"
			Key.KEY_9: input_id = "9"
		 
	if input_id != "":
		get_viewport().set_input_as_handled()
		
		if type == "INPUT":
			var ctl = ControlPanel.ControlInputs[input_id]
			var state
			if ctl.type == ControlInput.TYPE_SWITCH:
				state = ControlInput.ON if event.pressed else ControlInput.OFF
			else: 
				state = ControlInput.PRESSED if event.pressed else ControlInput.RELEASED
			
			emit_signal("simulated_control_input", ctl.id, state)
		elif type == "KEYPAD":
			if event.pressed:
				print("Key = ", input_id)
				emit_signal("keypad_event", input_id)
