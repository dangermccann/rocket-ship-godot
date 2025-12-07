extends Node

var Leds: Dictionary[String, Led] = {
	"STATUS-0_0": Led.new(0),
	"STATUS-0_1": Led.new(1),
	"STATUS-0_2": Led.new(2),
	"STATUS-0_3": Led.new(3),
	"STATUS-0_4": Led.new(4),
	"STATUS-1_0": Led.new(5),
	"STATUS-1_1": Led.new(6),
	"STATUS-1_2": Led.new(7),
	"STATUS-1_3": Led.new(8),
	"STATUS-1_4": Led.new(9),
	"STATUS-2_0": Led.new(10),
	"STATUS-2_1": Led.new(11),
	"STATUS-2_2": Led.new(12),
	"STATUS-2_3": Led.new(13),
	"STATUS-2_4": Led.new(14),
	
	"CONTROL-0": Led.new(18),
	"CONTROL-1": Led.new(19),
	"CONTROL-2": Led.new(20),
	"CONTROL-3": Led.new(21),
	"CONTROL-4": Led.new(15),
	"CONTROL-5": Led.new(16),
	"CONTROL-6": Led.new(17),
	
	"SECURITY-0": Led.new(22),
	"SECURITY-1": Led.new(23)
}
var ControlInputs: Dictionary[String, ControlInput] = {
	# Panel 1
	"BOOSTER_0": ControlInput.new(0, ControlInput.TYPE_BUTTON, "BOOSTER_0"),
	"BOOSTER_1": ControlInput.new(1, ControlInput.TYPE_BUTTON, "BOOSTER_1"),
	"BOOSTER_2": ControlInput.new(2, ControlInput.TYPE_BUTTON, "BOOSTER_2"),
	"BOOSTER_3": ControlInput.new(3, ControlInput.TYPE_BUTTON, "BOOSTER_3"),
	"BOOSTER_4": ControlInput.new(4, ControlInput.TYPE_BUTTON, "BOOSTER_4"),
	"BOOSTER_5": ControlInput.new(5, ControlInput.TYPE_BUTTON, "BOOSTER_5"),
	"BOOSTER_6": ControlInput.new(6, ControlInput.TYPE_BUTTON, "BOOSTER_6"),
	"BOOSTER_7": ControlInput.new(7, ControlInput.TYPE_BUTTON, "BOOSTER_7"),
	"BOOSTER_8": ControlInput.new(8, ControlInput.TYPE_BUTTON, "BOOSTER_8"),
	
	# Panel 2
	"ALARM_OVERRIDE": 	ControlInput.new(11,  ControlInput.TYPE_SWITCH, "ALARM_OVERRIDE"),
	"POWER": 			ControlInput.new(12, ControlInput.TYPE_SWITCH, "POWER"),
	"MODE": 			ControlInput.new(13, ControlInput.TYPE_SWITCH, "MODE"),
	"LAMP": 			ControlInput.new(9,  ControlInput.TYPE_BUTTON, "LAMP"),
	"ACK": 				ControlInput.new(10, ControlInput.TYPE_BUTTON, "ACK"),
	
	# Panel 3
	"PYRO_0": 	ControlInput.new(14,  ControlInput.TYPE_SWITCH, "PYRO_0"),
	"PYRO_1": 	ControlInput.new(15,  ControlInput.TYPE_SWITCH, "PYRO_1"),
	"PYRO_2": 	ControlInput.new(16,  ControlInput.TYPE_SWITCH, "PYRO_2"),
	"PYRO_3": 	ControlInput.new(17,  ControlInput.TYPE_SWITCH, "PYRO_3"),
	"PYRO_4": 	ControlInput.new(18,  ControlInput.TYPE_SWITCH, "PYRO_4"),
	"PYRO_5": 	ControlInput.new(19,  ControlInput.TYPE_SWITCH, "PYRO_5"),
	"PYRO_6": 	ControlInput.new(20,  ControlInput.TYPE_SWITCH, "PYRO_6"),
	
	# Panel 5 :: TODO analog knobs
	
	#Panel 6
	"DOCKING": 	ControlInput.new(24,  ControlInput.TYPE_SWITCH, "DOCKING"),
	"GLYCOL": 	ControlInput.new(23,  ControlInput.TYPE_SWITCH, "GLYCOL"),
	"SCE":	 	ControlInput.new(22,  ControlInput.TYPE_SWITCH, "SCE"),
	"WASTE": 	ControlInput.new(21,  ControlInput.TYPE_SWITCH, "WASTE"),
	
	# Panel 7
	# Joystick IDs 25 - 30
	
	# Panel 8
	"VERIFY": 	ControlInput.new(31,  ControlInput.TYPE_SWITCH, "VERIFY"),
	"BYPASS": 	ControlInput.new(32,  ControlInput.TYPE_SWITCH, "BYPASS"),
	"ARM":	 	ControlInput.new(33,  ControlInput.TYPE_SWITCH, "ARM"),
}

func _ready() -> void:
	GlobalEvents.serial_data_received.connect(on_serial_data_received)
	
func _process(delta: float) -> void:
	## TODO: there's got to be a better way to do this
	# Allow keyboard keys to simulate button presses
	if Input.is_action_just_pressed("BOOSTER_0"):
		process_control_input(0, ControlInput.PRESSED)
	if Input.is_action_just_released("BOOSTER_0"):
		process_control_input(0, ControlInput.RELEASED)

	if Input.is_action_just_pressed("BOOSTER_1"):
		process_control_input(1, ControlInput.PRESSED)
	if Input.is_action_just_released("BOOSTER_1"):
		process_control_input(1, ControlInput.RELEASED)
		
	
func on_serial_data_received(data):
	# Process specific joystick events
	if data.begins_with("INPUT:") or data.begins_with("KEY:"):
		var parts = data.split(":")
		if parts.size() == 3:
			var id = parts[1]
			var state = parts[2]
			
			if data.begins_with("INPUT:"):
				process_control_input(id.to_int(), state)
			elif data.begins_with("KEY:"):
				process_key(id, state)

	
func process_control_input(id, state):
	var ctl: ControlInput = ControlPanel.find_control_input(id)
	if ctl != null:
		ctl.set_state(state)
		
	if id >= 25 and id <= 30:
		process_joystick_input(id, state)

func process_joystick_input(id, state):
	var direction = ''
	
	match id:
		25: direction = 'up'	
		26: direction = 'down'	
		27: direction = 'right'	
		28: direction = 'left'	
		29: direction = 'trigger_top'	
		30: direction = 'trigger_front'	

	var action_name = "joystick_" + direction
	var pressed = false 
	if state == "PRESSED":
		pressed = true
	
	# Emit the clean joystick event
	GlobalEvents.emit_signal("joystick_input_event", action_name, pressed)
	
func process_key(key_id, state):
	GlobalEvents.emit_signal("keypad_event", key_id)

func find_control_input(id:int) -> ControlInput:
	var keys: Array[String] = ControlInputs.keys()
	for n in keys:
		var ctl: ControlInput = ControlInputs[n]
		if ctl.id == id:
			return ctl
	return null

func refresh_state():
	GlobalEvents.emit_signal("serial_message", "STATUS:0:10")
