extends CanvasLayer

@onready var heading = $Panel/Heading
@onready var count = $Panel/Count

func _ready() -> void:
	MissionManager.mission_progress.connect(_on_mission_progress)
	MissionManager.mission_started.connect(_on_mission_started)
	
func _on_mission_started(mission: MissionData):
	if mission.type == MissionData.MissionType.OBSTICLE_REMOVAL:
		heading.text = mission.target_obsticle + "s"
	elif mission.type == MissionData.MissionType.ITEM_COLLECTION:
		heading.text = mission.target_item + "s"
	
func _on_mission_progress(mission: MissionData, progress: int):
	count.text = str(progress)
