class_name MissionData
extends Resource

@export var mission_id: String
@export var title: String
@export var description: String

enum MissionType {
	CONTROL_INPUT_STATE,
	CONTROL_INPUT_SEQUENCE,
	ITEM_COLLECTION,
	OBSTICLE_REMOVAL
}

@export var type: MissionType

# The target to reach to complete the mission. Type dependent. 
@export var target: int

# How much time to allow for the mission before failure
@export var time_target: float

# For CONTROL_INPUT_STATE missions
# Dictionary of input ID to input state
# Expects all inputs to be in the provided state 
# to satisfy the mission
@export var target_state: Dictionary[String, String]

# For CONTROL_INPUT_SEQUENCE missions
# Array of input IDs to be entered in order.
# Progress is reset if an input is not the next one
# in the sequence. 
@export var target_sequence: Array[String]

# For ITEM_COLLECTION missions
# The type of item that must be collected (e.g. snakes) 
@export var target_item: String

# For OBSTICLE_REMOVAL missions
# The type of obsticle to remove (e.g. astroid) 
@export var target_obsticle: String
