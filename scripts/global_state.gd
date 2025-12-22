extends Node

const GAME_STATE_EXPLORE = "EXPLORE"
const GAME_STATE_LANDING = "LANDING"
const GAME_STATE_GROUND  = "GROUND"

const UI_STATE_NONE = "NONE"
const UI_STATE_WARP = "WARP"
const UI_STATE_ENTER_SEQUENCE = "ENTER_SEQUENCE"
const UI_STATE_COLLECTION = "COLLECTION"
const UI_STATE_PANEL_1 = "PANEL_1"
const UI_STATE_PANEL_2 = "PANEL_2"
const UI_STATE_PANEL_3 = "PANEL_3"

var game_state = GAME_STATE_EXPLORE
var ui_state = UI_STATE_NONE
var modal: Node

var Modals: Dictionary[String, Resource] = {
	UI_STATE_WARP: preload("res://scenes/ui/warp.tscn"),
	UI_STATE_ENTER_SEQUENCE: preload("res://scenes/ui/missions/enter_sequence.tscn"),
	UI_STATE_COLLECTION: preload("res://scenes/ui/missions/collection_mission_ui.tscn"),
	UI_STATE_PANEL_1: preload("res://scenes/ui/missions/panel_1.tscn"),
	UI_STATE_PANEL_2: preload("res://scenes/ui/missions/panel_2.tscn"),
	UI_STATE_PANEL_3: preload("res://scenes/ui/missions/panel_3.tscn"),
}

func _ready() -> void:
	GlobalEvents.ui_modal_closed.connect(_on_ui_modal_closed)

func _on_ui_modal_closed():
	ui_state = UI_STATE_NONE

func modal_ui(id: String) -> Node:
	if ui_state == UI_STATE_NONE:
		var scene: Resource = Modals[id]
		modal = scene.instantiate()
		get_tree().root.add_child(modal)
		ui_state = id
		return modal
	return null
