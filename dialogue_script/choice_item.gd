extends Control
class_name ChoiceItem

@onready var heart: TextureRect = $Heart
@onready var label: Label = $Text


func set_text(t: String) -> void:
	label.text = t

func set_selected(sel: bool) -> void:
	heart.visible = sel

func get_center() -> Vector2:
	return global_position + size / 2.0
