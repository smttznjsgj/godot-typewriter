extends Resource
class_name DialogueGroup

@export var dialogue_list : Array[Dialogue]

@export var id: String = ""
@export var next_id: String = ""
@export_group("Flags and Event")
@export var require_flag: String = ""
@export var set_flag: String = ""
@export_group("Choices")
@export var choices: Array[String] = []
@export var choice_next_ids: Array[String] = []
