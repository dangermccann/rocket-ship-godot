extends Node3D
@onready var boosters_node = $RootNode/Boosters

func enable_boosters(on: bool):
	var led = ControlPanel.Leds[ControlPanel.THRUST]
	if on:
		boosters_node.visible = true
		led.on()
	else:
		boosters_node.visible = false
		led.off()
