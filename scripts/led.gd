class_name Led

var id:int 
var state:String

const ON = "ON"
const OFF = "OFF"
const BLINK = "BLINK"

func _init(_id:int):
	id = _id
	state = "UNKNOWN"

func on():
	if state != ON:
		send("LED:" + str(id) + ":ON")
		state = ON
	
func off():
	if state != OFF:
		send("LED:" + str(id) + ":OFF")
		state = OFF
	
func blink():
	if state != BLINK:
		send("LED:" + str(id) + ":BLINK")
		state = BLINK
	
func send(msg:String):
	GlobalEvents.emit_signal("serial_message", msg)
