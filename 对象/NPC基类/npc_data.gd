extends StaticBody2D
#NPC，复杂的箱子用这个
@export_group("Normal")

@export var dialogue_groups : Array[DialogueGroup]


@export_group("Advanced")
@export var only_once :bool = false
@export var reward_gold : int
@export var item : Array
@export var sound : Resource

var current_group_id: String = ""

func _ready() -> void:
	if dialogue_groups.size() > 0:
		current_group_id = dialogue_groups[0].id
	Global.dialogue_broadcast.connect(_on_broadcast)
func interact() -> void:
	var group := _find_group(current_group_id)
	if group:
		DialogueUI.start_dialogue(group)
		DialogueUI.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

func _on_dialogue_finished() -> void:
	pass


#func _on_dialogue_finished() -> void:
	#var finished := _find_group(current_group_id)
	#if finished and finished.next_id != "":
		#current_group_id = finished.next_id
		
func _find_group(target_id: String) -> DialogueGroup:
	for g in dialogue_groups:
		if g.id == target_id:
			return g
	return null

func _on_broadcast(next_id: String) -> void:
	if next_id == "":
		return
	var group := _find_group(next_id)
	if group:
		current_group_id = next_id
