class_name Led

var id:int 
var state:String

func _init(_id:int):
	id = _id
	state = "OFF"

func on():
	send("LED:" + str(id) + ":ON")
	state = "On"
	pass
	
func off():
	send("LED:" + str(id) + ":OFF")
	state = "Off"
	pass
	
func blink():
	send("LED:" + str(id) + ":BLINK")
	state = "BLINK"
	pass
	
func send(msg:String):
	GlobalEvents.emit_signal("serial_message", msg)
