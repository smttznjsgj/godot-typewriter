extends StaticBody2D

@export_group("Normal")
@export var sprite : Texture
@export var first_open_dialogue : DialogueGroup
@export var empty_dialogue : DialogueGroup


@export_group("Advanced")
@export var only_once :bool = false
@export var reward_gold : int
@export var item : Array
@export var sound : Resource


@export var has_been_opened: bool = false

func interact() -> void:
	if has_been_opened:
		DialogueUI.start_dialogue(empty_dialogue)
	else:	
		DialogueUI.start_dialogue(first_open_dialogue)
		DialogueUI.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		has_been_opened = true

func _on_dialogue_finished() -> void:
	
	Global.player.inventory.append("match")
	print("you got %s" % Global.player.inventory)
	
