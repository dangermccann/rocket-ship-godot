class_name ControlInput

const TYPE_BUTTON: String = "BUTTON"
const TYPE_SWITCH: String = "SWITCH"
const PRESSED: String	  = "PRESSED"
const RELEASED: String	  = "RELEASED"
const ON: String		  = "ON"
const OFF: String		  = "OFF"

var id:int 
var state:String
var type:String
var full_id:String

func _init(_id:int, _type:String, _full_id: String):
	id = _id
	type = _type
	full_id = _full_id
	if(type == TYPE_BUTTON):
		state = "RELEASED"
	else:
		state = "OFF"
	
func set_state(new_state:String):
	if state != new_state:
		state = new_state
		GlobalEvents.emit_signal("input_state_changed", id, state)
		print(full_id, " = ", state)
