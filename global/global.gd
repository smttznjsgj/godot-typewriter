extends Node

var can_act : bool = true
var player : PlayerData

func _ready() -> void:
	player = preload("res://player/player_data.tres")
