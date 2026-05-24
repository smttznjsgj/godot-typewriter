extends Resource
class_name Dialogue

@export_group("Normal")
@export var character_name : String
@export_multiline var content : String
@export var avatar : Texture
@export var show_on_left : bool
@export var typing_sound : AudioStream

@export_group("Advanced")
@export var typing_speed : float = 0.05
@export var text_color: Color = Color.WHITE
@export var text_font : Font = preload("res://素材/Fonts/方正像素12.ttf")
@export var effect: Array[EffectData] = []
