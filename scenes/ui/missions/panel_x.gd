extends Control

const HIDE_COLOR = Color(1, 1, 1, 0.2)

var current_mission: MissionData
var time_left = 0 
@onready var panel = $Panel
@onready var progress: ProgressBar = $Panel/ProgressBar

func set_mission(m: MissionData):
	current_mission = m
	time_left = current_mission.time_target
	refresh()
	
func refresh():
	if current_mission.target_state == null:
		return
		
	var container = panel
	if panel.get_child(0) is GridContainer:
		container = panel.get_child(0)

	for child in container.get_children():
		var ci = child as CanvasItem
		if current_mission.target_state.keys().has(child.name):
			ci.modulate = Color.WHITE
		else:
			ci.modulate = HIDE_COLOR

func _process(delta: float) -> void:
	if progress != null and current_mission != null and current_mission.time_target > 0:
		progress.visible = true
		
		time_left = time_left - delta
		progress.value = time_left / current_mission.time_target * 100
	else:
		progress.visible = false
