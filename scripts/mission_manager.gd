extends Node

signal mission_started(mission: MissionData)
signal mission_progress(mission: MissionData, current: int)
signal mission_completed(mission: MissionData)
signal mission_failed(mission: MissionData)

var current_mission: MissionData
var current_progress: int
var current_time: float

const COLLECTION_EVENT = "COLLECTION"
const REMOVAL_EVENT = "REMOVAL"

func _ready() -> void:
	GlobalEvents.input_state_changed.connect(_on_input_state_changed)
	GlobalEvents.keypad_event.connect(_on_keypad_event)

func _process(delta: float) -> void:
	if current_mission != null:
		current_time += delta
		
		# Check to see if too much time has passed and the mission should fail
		if current_mission.time_target > 0 and current_time > current_mission.time_target:
			fail()

func _on_input_state_changed(full_id, state):
	if current_mission == null:
		return
		
	if current_mission.type == MissionData.MissionType.CONTROL_INPUT_STATE:
		var is_match: bool = true
		
		# 1. Iterate through all target states 
		for key in current_mission.target_state.keys():
			# 2. Get the matching control input 
			var ctl = ControlPanel.ControlInputs[key]
			# 3. Compare the input state to the target 
			if ctl.state != current_mission.target_state[key]:
				is_match = false
		
		if is_match:
			current_progress = 1
		
		_check_complete()
	
	elif current_mission.type == MissionData.MissionType.CONTROL_INPUT_SEQUENCE:
		if state == ControlInput.PRESSED or state == ControlInput.ON:
			check_sequence_input(full_id)
	
	
func _on_keypad_event(key):
	if current_mission == null:
		return
		
	if current_mission.type == MissionData.MissionType.CONTROL_INPUT_SEQUENCE:
		check_sequence_input(key)

func check_sequence_input(input):
	if current_mission.target_sequence[current_progress] == input:
		current_progress += 1 
		emit_signal("mission_progress", current_mission, current_progress)
		_check_complete()
	else:
		current_progress	 = 0
		emit_signal("mission_progress", current_mission, current_progress)

func start_mission(mission: MissionData):
	current_mission = mission
	current_progress = 0
	current_time = 0
	emit_signal("mission_started", current_mission)
	print("Starting mission ", mission.title)
	
func log_event(event: String, data: Dictionary[String, String]):
	if current_mission == null:
		return
	
	if current_mission.type == MissionData.MissionType.ITEM_COLLECTION and event == COLLECTION_EVENT:
		if data["type"] == current_mission.target_item:
			record_progress(int(data["quantity"]))

	if current_mission.type == MissionData.MissionType.OBSTICLE_REMOVAL and event == REMOVAL_EVENT:
		if data["type"] == current_mission.target_item:
			record_progress(int(data["quantity"]))

func record_progress(progress: int):
	current_progress += progress
	emit_signal("mission_progress", current_mission, current_progress)
	_check_complete()

func fail():
	emit_signal("mission_failed", current_mission)
	print("Failed mission ", current_mission.title)
	current_mission = null
	
func _check_complete():
	if current_progress >= current_mission.target:
		emit_signal("mission_completed", current_mission)
		print("Completed mission ", current_mission.title)
		
		# TODO: figure out where to keep track of completed missions / achievements 
		# TODO: figure out who will respond to these emitted signals and play audio 
		current_mission = null
