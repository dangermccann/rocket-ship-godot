extends Control

func _on_close_button_pressed() -> void:
	close()

func close():
	GlobalEvents.emit_signal("ui_modal_closed")
	queue_free()

func _on_aquaris_button_pressed() -> void:
	GlobalEvents.emit_signal("warp_to", Planets.AQUARIS)
	close()

func _on_cyberion_prime_button_pressed() -> void:
	GlobalEvents.emit_signal("warp_to", Planets.CYBERION_PRIME)
	close()

func _on_echo_station_button_pressed() -> void:
	GlobalEvents.emit_signal("warp_to", Planets.ECHO_STATION)
	close()

func _on_frostbit_button_pressed() -> void:
	GlobalEvents.emit_signal("warp_to", Planets.FROSTBIT)
	close()

func _on_gloop_button_pressed() -> void:
	GlobalEvents.emit_signal("warp_to", Planets.GLOOP)
	close()

func _on_volcania_button_pressed() -> void:
	GlobalEvents.emit_signal("warp_to", Planets.VOLCANIA)
	close()
