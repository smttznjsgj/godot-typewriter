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
		DialogueUI.dialogue_continue.connect(_on_dialogue_continue, CONNECT_ONE_SHOT)
func _on_dialogue_finished() -> void:
	if DialogueUI.dialogue_continue.is_connected(_on_dialogue_continue):
		DialogueUI.dialogue_continue.disconnect(_on_dialogue_continue)
func _on_dialogue_continue() -> void:
	var group := _find_group(current_group_id)
	if group:
		DialogueUI.start_dialogue(group)
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
	if group and _check_flags(group.require_flag):
		current_group_id = next_id
		
func _check_flags(flag_str: String) -> bool:
	if flag_str == "":
		return true
	for f in flag_str.split(","):
		if not Global.has_flag(f.strip_edges()):
			return false
	return true
