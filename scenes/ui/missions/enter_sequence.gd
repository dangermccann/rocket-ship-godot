extends CanvasLayer

var current_mission: MissionData
var time_left = 0 
@onready var progress: ProgressBar = $ProgressBar
@onready var label1: Label = $Panel/Label1
@onready var label2: Label = $Panel/Label2
@onready var label3: Label = $Panel/Label3
@onready var label4: Label = $Panel/Label4

func set_mission(m: MissionData):
	current_mission = m
	
	if current_mission == null or current_mission.target_sequence.size() < 4:
		return
	
	label1.text = current_mission.target_sequence[0]
	label2.text = current_mission.target_sequence[1]
	label3.text = current_mission.target_sequence[2]
	label4.text = current_mission.target_sequence[3]
	
func _process(delta: float) -> void:
	if progress != null and current_mission != null and current_mission.time_target > 0:
		progress.visible = true
		
		time_left = time_left - delta
		progress.value = time_left / current_mission.time_target * 100
	else:
		progress.visible = false
