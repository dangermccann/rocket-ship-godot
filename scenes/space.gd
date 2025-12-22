extends Node3D


const MISSION_COMPLETE_UI = preload("res://scenes/ui/missions/mission_complete.tscn")
const MISSION_FAILED_UI = preload("res://scenes/ui/missions/mission_failed.tscn")
const ASTROID_BELT = preload("res://scenes/astroid_belt.tscn")
const ICE_BELT = preload("res://scenes/ice_belt.tscn")

const MAIN_SCENE: String = "res://scenes/space.tscn"

@onready var rotations: AnimationPlayer = $PlanetRotator
@onready var ship: Node3D = $SpaceShipParent
@onready var belt_parent: Node3D = $Belt

var mission_container: Node3D = null


func _ready() -> void:
	# TODO: why doesn't this rotate?
	rotations.play("Aquaris")
	
	MissionManager.mission_completed.connect(_on_mission_completed)
	MissionManager.mission_failed.connect(_on_mission_failed)
	GlobalEvents.arrived_at_planet.connect(_on_arrived_at_planet)
	
	ship.ship_destroyed.connect(_on_ship_destroyed)
	
	# Set up some of the status lights
	ControlPanel.Leds[ControlPanel.AC_BUS_1].on()
	ControlPanel.Leds[ControlPanel.AC_BUS_2].blink()
	ControlPanel.Leds[ControlPanel.O2_FLOW].on()
	
	ControlPanel.Leds[ControlPanel.CABIN_FAN].on()
	ControlPanel.Leds[ControlPanel.H20_FLOW].blink()
	ControlPanel.Leds[ControlPanel.INT_LIGHTS].on()
	
	# Clear critial alert LED
	ControlPanel.Leds[ControlPanel.CRITICAL_ALERT].off()
	
func _on_mission_completed(mission):
	var node = MISSION_COMPLETE_UI.instantiate()
	get_tree().root.add_child(node)
	
	await get_tree().create_timer(1.0).timeout
	Sounds.play_sound(Sounds.MISSION_COMPLETE_AUDIO)
	
	
func _on_mission_failed(mission):
	var node = MISSION_FAILED_UI.instantiate()
	get_tree().root.add_child(node)
	
	await get_tree().create_timer(1.0).timeout
	Sounds.play_sound(Sounds.MISSION_FAILED_AUDIO)
	
	if mission_container != null:
		mission_container.queue_free()
		mission_container = null
	
func _on_ship_destroyed():
	# Critical alert LED
	ControlPanel.Leds[ControlPanel.CRITICAL_ALERT].on()
	MissionManager.fail_mission()
	
	await get_tree().create_timer(2.0).timeout
	
	# https://github.com/godotengine/godot/issues/85852
	#get_tree().change_scene_to_file(MAIN_SCENE)
	get_tree().change_scene_to_file.bind(MAIN_SCENE).call_deferred()
	
func _on_arrived_at_planet(planet):
	match planet:
		"Aquaris":
			load_mission("aquaris_mission")
		"Volcania":
			load_mission("volcania_mission")
		"Cyberion Prime":
			load_mission("cyberion_prime_mission")
		"Echo Station":
			load_mission("echo_station_mission")
		"Frostbit":
			load_mission("frostbit_mission")
		"Gloop":
			load_mission("gloop_mission")
	
	
func load_mission(mission_id):
	var mission: MissionData = load("res://missions/" + mission_id + ".tres") as MissionData
	MissionManager.call_deferred("start_mission", mission)
	
	if mission.start_audio != null:
		Sounds.play_sound(mission.start_audio)
		
	if mission_id == "echo_station_mission":			
		load_belt(ASTROID_BELT, Vector3(0, 0, -20))
	if mission_id == "frostbit_mission":
		load_belt(ICE_BELT, Vector3(0, 0, 0))

func load_belt(resource: Resource, offset: Vector3):
	if mission_container != null:
		mission_container.queue_free()
			
	mission_container = resource.instantiate()
	belt_parent.add_child(mission_container)
	mission_container.global_position = ship.global_position + offset
	mission_container.rotation.y = ship.camera_node.rotation.y
