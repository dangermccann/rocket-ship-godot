extends Node

const GAME_STATE_EXPLORE = "EXPLORE"
const GAME_STATE_LANDING = "LANDING"
const GAME_STATE_GROUND  = "GROUND"

const UI_STATE_NONE = "NONE"
const UI_STATE_WARP = "WARP"

var game_state = GAME_STATE_EXPLORE
var ui_state = UI_STATE_NONE

var Modals: Dictionary[String, Resource] = {
	"WARP": preload("res://scenes/ui/warp.tscn")
}

func _ready() -> void:
	GlobalEvents.ui_modal_closed.connect(_on_ui_modal_closed)

func _on_ui_modal_closed():
	ui_state = UI_STATE_NONE

func modal_ui(id: String):
	if ui_state == UI_STATE_NONE:
		var scene: Resource = Modals[id]
		var instance = scene.instantiate()
		get_tree().root.add_child(instance)
		ui_state = id
