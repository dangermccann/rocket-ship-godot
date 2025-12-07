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
signal input_state_changed(input_id, state)

# Signal emitted when an input control changes state
signal booster_button(button)

signal ui_modal_closed()

signal warp_to(planet)
