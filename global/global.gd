extends Node

var can_act : bool = true
var player : PlayerData

signal dialogue_broadcast(next_id: String)

func _ready() -> void:
	player = preload("res://player/player_data.tres")
