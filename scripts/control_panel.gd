extends Node

const CRITICAL_ALERT 	= "STATUS-0_0"
const HATCH 			= "STATUS-0_1"
const AC_BUS_1 			= "STATUS-0_2"
const MN_BUSS_B 		= "STATUS-0_3"
const GLYCOL_TEMP 		= "STATUS-0_4"
const CYRO_PRESS 		= "STATUS-1_0"
const DOCKING_TARGET 	= "STATUS-1_1"
const AC_BUS_2 			= "STATUS-1_2"
const CREW_ALERT		= "STATUS-1_3"
const ULAGE 			= "STATUS-1_4"
const THRUST 			= "STATUS-2_0"
const SPS_PRESS 		= "STATUS-2_1"
const SPS_ROUGH_ECO 	= "STATUS-2_2"
const SUIT_COMP 		= "STATUS-2_3"
const O2_FLOW 			= "STATUS-2_4"

const DOCKING_PROBE 	= "CONTROL-0"
const GLYCOL_PUMP 		= "CONTROL-1"
const SCE_POWER 		= "CONTROL-2"
const WASTE_DUMP 		= "CONTROL-3"
const CABIN_FAN 		= "CONTROL-4"
const H20_FLOW 			= "CONTROL-5"
const INT_LIGHTS 		= "CONTROL-6"


var Leds: Dictionary[String, Led] = {
	CRITICAL_ALERT: Led.new(0),
	HATCH: Led.new(1),
	AC_BUS_1: Led.new(2),
	MN_BUSS_B: Led.new(3),
	GLYCOL_TEMP: Led.new(4),
	CYRO_PRESS: Led.new(5),
	DOCKING_TARGET: Led.new(6),
	AC_BUS_2: Led.new(7),
	CREW_ALERT: Led.new(8),
	ULAGE: Led.new(9),
	THRUST: Led.new(10),
	SPS_PRESS: Led.new(11),
	SPS_ROUGH_ECO: Led.new(12),
	SUIT_COMP: Led.new(13),
	O2_FLOW: Led.new(14),
	
	DOCKING_PROBE: Led.new(18),
	GLYCOL_PUMP: Led.new(19),
	SCE_POWER: Led.new(20),
	WASTE_DUMP: Led.new(21),
	CABIN_FAN: Led.new(15),
	H20_FLOW: Led.new(16),
	INT_LIGHTS: Led.new(17),
	
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
 	"JOYSTICK_UP": ControlInput.new(25, ControlInput.TYPE_BUTTON, "JOYSTICK_UP"),
	"JOYSTICK_DOWN": ControlInput.new(26, ControlInput.TYPE_BUTTON, "JOYSTICK_DOWN"),
	"JOYSTICK_RIGHT": ControlInput.new(27, ControlInput.TYPE_BUTTON, "JOYSTICK_RIGHT"),
	"JOYSTICK_LEFT": ControlInput.new(28, ControlInput.TYPE_BUTTON, "JOYSTICK_LEFT"),
	"JOYSTICK_TT": ControlInput.new(29, ControlInput.TYPE_BUTTON, "JOYSTICK_TT"),
	"JOYSTICK_TF": ControlInput.new(30, ControlInput.TYPE_BUTTON, "JOYSTICK_TF"),
	
	# Panel 8
	"VERIFY": 	ControlInput.new(31,  ControlInput.TYPE_SWITCH, "VERIFY"),
	"BYPASS": 	ControlInput.new(32,  ControlInput.TYPE_SWITCH, "BYPASS"),
	"ARM":	 	ControlInput.new(33,  ControlInput.TYPE_SWITCH, "ARM"),
}

var AnalogInputs: Dictionary[String, int] = {
	"ANALOG_0": 0,
	"ANALOG_1": 0,
}

func _ready() -> void:
	GlobalEvents.serial_data_received.connect(_on_serial_data_received)
	GlobalEvents.simulated_control_input.connect(_on_simulated_control_input)

func _on_serial_data_received(data):
	# Process specific joystick events
	if data.begins_with("INPUT:") or data.begins_with("KEY:") or data.begins_with("ANALOG:"):
		var parts = data.split(":")
		if parts.size() == 3:
			var id = parts[1]
			var state = parts[2]
			
			if data.begins_with("INPUT:"):
				process_control_input(id.to_int(), state)
			elif data.begins_with("KEY:"):
				process_key(id, state)
			elif data.begins_with("ANALOG:"):
				process_analog(id, state)

func _on_simulated_control_input(id, state):
	process_control_input(id, state)
	
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

func process_analog(id, state):
	var full_id = null
	var val = int(state)
	
	match id:
		"A0": full_id = "ANALOG_0"
		"A1": full_id = "ANALOG_1"
	
	if full_id != null:
		AnalogInputs[full_id] = val
		GlobalEvents.emit_signal("input_state_changed", full_id, val)

func find_control_input(id:int) -> ControlInput:
	var keys: Array[String] = ControlInputs.keys()
	for n in keys:
		var ctl: ControlInput = ControlInputs[n]
		if ctl.id == id:
			return ctl
	return null

func refresh_state():
	GlobalEvents.emit_signal("serial_message", "STATUS:0:10")
