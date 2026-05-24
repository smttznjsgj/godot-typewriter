extends Control

@export_group("UI")
@export var character_name_text : Label
@export var text_box : Label
@export var left_avatar: TextureRect
@export var right_avatar : TextureRect
@onready var end_hint: Label = $end_hint
@onready var typing_audio: AudioStreamPlayer = $TypingAudio
@onready var dialogue_box: HBoxContainer = $DialogueBox
@onready var shake_audio: AudioStreamPlayer = $ShakeAudio



@export_group("dialogue")
@export var main_dialogue :DialogueGroup

@export_group("Advanced")


signal dialogue_finished

var default_typing_sound : AudioStream = preload("res://素材/声音/SND_TXT1.wav")
var current_typing_sound : AudioStream
var typing_tween : Tween
var dialogue_index : int = 0
var blink_tween: Tween
var effect_tween : Tween



func display_next_dialogue() -> void:
	end_hint.modulate.a = 0.0
	#杀干净残留的tween
	if blink_tween and blink_tween.is_running():
		blink_tween.kill()
	if effect_tween and effect_tween.is_running():
		effect_tween.kill()
	#判断是否结束对话组
	if dialogue_index >= len(main_dialogue.dialogue_list):
		Global.can_act = true
		visible = false
		dialogue_finished.emit()
		return
	
	var dialogue := main_dialogue.dialogue_list[dialogue_index]
	var processed_content = dialogue.content.replace("{name}",Global.player.player_name)
	#加个冒号就相当与把这个dialogue定义为了一个局部类，后面就可以引用了？
	
	if typing_tween and typing_tween.is_running():
		var dead_tween = typing_tween
		typing_tween = null
		dead_tween.kill()
		text_box.text = processed_content
		#对话结束后的小光标
		end_hint.modulate.a = 1.0
		blink_tween = get_tree().create_tween().set_loops()
		blink_tween.tween_property(end_hint,"modulate:a",0.2,0.4)
		blink_tween.tween_property(end_hint,"modulate:a",1.0,0.4)
		dialogue_index += 1
		return
	else:
		character_name_text.text = dialogue.character_name
		current_typing_sound = dialogue.typing_sound if dialogue.typing_sound else default_typing_sound
		#text_box.text = dialogue.content   
		#如果不用打字机的话，这一行就可以不注释掉，但是我们要用打字机来显示这个文本，所以我们来把这个注释掉吧！！
		
		#打字机：
		#判断是否有高级效果
		for ef in dialogue.effect:
			var box = dialogue_box
			var ox = box.position.x
			var oy = box.position.y
			#接下来上音效
			if ef.effect_sound:
				shake_audio.stream = ef.effect_sound
				shake_audio.play()
			#这里匹配状态机
			if ef is ShakeEffect:
				var sh = ef as ShakeEffect
				effect_tween = get_tree().create_tween()
				for i in sh.count:
					var sign = 1 if i % 2 == 0 else -1
					effect_tween.tween_property(box, "position:x", ox+sh.magnitude_x*sign,sh.speed)
					effect_tween.tween_property(box, "position:y", oy+sh.magnitude_y*sign,sh.speed)
				effect_tween.tween_property(box, "position:x", ox, sh.speed)
				effect_tween.tween_property(box, "position:y", oy, sh.speed)
					#抖动到此结束
			elif ef is WobbleEffect:
				var wo  = ef as WobbleEffect
				effect_tween = get_tree().create_tween()
				for i in wo.count:
					var sign = 1 if i % 2 == 0 else -1
					effect_tween.tween_property(box,"rotation_degrees",wo.rotation*sign,wo.speed)
				effect_tween.tween_property(box,"rotation_degrees",0,wo.speed)
					
			
			
			
		typing_tween = get_tree().create_tween()
		text_box.text = ""
		text_box.add_theme_color_override("font_color",dialogue.text_color)
		text_box.add_theme_font_override("font",dialogue.text_font)
		for character in processed_content:
			typing_tween.tween_callback(append_character.bind(character)).set_delay(dialogue.typing_speed)#这里的.bind，是因为callback函数调用的括号里面的函数不能直接加括号，所以加上一个.bind来兼容一下？
			if character in [".", "!", "?", "。", "！", "？"]:
				typing_tween.tween_interval(0.4)
			elif character in [",", "，", ";", "；", ":", "："]:
				typing_tween.tween_interval(0.15)
		typing_tween.tween_callback(
			func(): #这里使用了匿名函数的调用，因为callback只能喊一个函数名，但是我们需要只有这一个句子，所以我们就把他给扣上一个匿名函数的帽子
			dialogue_index += 1
			
			end_hint.modulate.a = 1.0
			blink_tween = get_tree().create_tween().set_loops()
			blink_tween.tween_property(end_hint,"modulate:a",0.2,0.4)
			blink_tween.tween_property(end_hint,"modulate:a",1.0,0.4)
			
			)
			
		if dialogue.show_on_left:
			left_avatar.texture = dialogue.avatar
			right_avatar.texture = null#材质设置为null，相当于不显示
		else :
			right_avatar.texture = dialogue.avatar
			left_avatar.texture = null
			
	

func append_character(character : String)-> void:
	if typing_tween == null:
		return
	text_box.text += character
	if current_typing_sound:
		typing_audio.stream = current_typing_sound
		typing_audio.play()




func _ready() -> void:
	visible = false
	current_typing_sound = default_typing_sound
	
	
func start_dialogue(group:DialogueGroup)-> void:
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
	typing_tween = null
	main_dialogue = group
	dialogue_index = 0
	visible = true
	Global.can_act = false
	display_next_dialogue()

















func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact"):
		display_next_dialogue()


#kkk



		
