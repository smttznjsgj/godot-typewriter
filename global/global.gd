extends Node

var can_act : bool = true
var player : PlayerData

signal dialogue_broadcast(next_id: String)

var flags: Dictionary = {}

func _ready() -> void:
	player = preload("res://player/player_data.tres")
	_setup_window.call_deferred()

func _setup_window() -> void:
	get_window().min_size = Vector2i(800, 500)

func set_flag(flag_name: String) -> void:
	if flag_name != "":
		flags[flag_name] = true
		print("Flag set: ", flag_name)

func has_flag(flag_name: String) -> bool:
	if flag_name == "":
		return true
	return flags.get(flag_name, false)
