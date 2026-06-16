extends Resource
class_name Dialogue


@export_multiline var content : String
@export var avatar : Texture
@export var typing_sound : AudioStream


@export_group("Normal")
@export var character_name : String
@export var show_on_left : bool
@export_group("Advanced")
@export var effect_sound: AudioStream
@export var typing_speed : float = 0.05
@export var text_color: Color = Color.WHITE
@export var text_font : Font = preload("res://素材/Fonts/方正像素12.ttf")
@export var effect: Array[EffectData] = []
## 效果跨句延续：true=快进不打断摇晃，false=效果结束后才允许推进下一句，针对效果比较长的对话，如果为false，则在对话结束后按下快进，先归位结束效果。ps.如果想制作那种比较长的效果，请把count调一个雷霆大数，确保其一时半会不会停
@export var persist_effects: bool = false
