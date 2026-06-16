extends Control

@export_group("UI")
@export var character_name_text : Label
@export var text_box : Label
@export var left_avatar: TextureRect
@export var right_avatar : TextureRect

@onready var typing_audio: AudioStreamPlayer = $TypingAudio
@onready var dialogue_box: HBoxContainer = $container/DialogueBox

@onready var end_hint: Label = %end_hint
@onready var container: Control = $container

@onready var shake_audio: AudioStreamPlayer = $ShakeAudio
@onready var choice_buttons: Array[Button] = [
	$container/Choicecontainer/Choice1,
	$container/Choicecontainer/Choice2,
	$container/Choicecontainer/Choice3,
	$container/Choicecontainer/Choice4
]
var choices_active: bool = false

@export_group("dialogue")
@export var main_dialogue :DialogueGroup

@export_group("Advanced")


signal dialogue_finished
signal dialogue_continue#给选项功能用的

var default_typing_sound : AudioStream = preload("res://素材/声音/SND_TXT1.wav")
var current_typing_sound : AudioStream
var typing_tween : Tween
var dialogue_index : int = 0
var blink_tween: Tween
var effect_tween : Tween
var persistent_effect_running: bool = false

func display_next_dialogue() -> void:
	end_hint.modulate.a = 0.0
	if blink_tween and blink_tween.is_running():
		blink_tween.kill()
	
	if effect_tween and effect_tween.is_running() and not persistent_effect_running:
		effect_tween.kill()
		persistent_effect_running = false
		var settle = get_tree().create_tween()
		settle.set_ease(Tween.EASE_OUT)
		settle.set_trans(Tween.TRANS_ELASTIC)
		settle.tween_property(container, "position:x", 0.0, 0.5)
		settle.parallel().tween_property(container, "position:y", 0.0, 0.5)
		settle.parallel().tween_property(container, "rotation_degrees", 0.0, 0.5)
		settle.tween_callback(display_next_dialogue)
		return
	
	#if dialogue_index >= len(main_dialogue.dialogue_list):
		#if effect_tween and effect_tween.is_running():
			#effect_tween.kill()
		#persistent_effect_running = false
		#container.position = Vector2.ZERO
		#container.rotation_degrees = 0.0
		#Global.can_act = true
		#visible = false
		#Global.set_flag(main_dialogue.set_flag)
		#Global.dialogue_broadcast.emit(main_dialogue.next_id)
		#dialogue_finished.emit()
		#return万一改错了用这个
	
	if dialogue_index >= len(main_dialogue.dialogue_list):
		if effect_tween and effect_tween.is_running():
			effect_tween.kill()
		if not main_dialogue.choices.is_empty():
			_show_choices(main_dialogue)
			return
		_finish_dialogue()
		return
	var dialogue := main_dialogue.dialogue_list[dialogue_index]
	var processed_content = dialogue.content.replace("{name}", Global.player.player_name)
	
	if typing_tween and typing_tween.is_running():
		var dead_tween = typing_tween
		typing_tween = null
		dead_tween.kill()
		text_box.text = processed_content
		end_hint.modulate.a = 1.0
		blink_tween = get_tree().create_tween().set_loops()
		blink_tween.tween_property(end_hint, "modulate:a", 0.2, 0.4)
		blink_tween.tween_property(end_hint, "modulate:a", 1.0, 0.4)
		if not persistent_effect_running and effect_tween and effect_tween.is_running():
			dialogue_index += 1
			return
		dialogue_index += 1
		return
	else:
		character_name_text.text = dialogue.character_name
		current_typing_sound = dialogue.typing_sound if dialogue.typing_sound else default_typing_sound
		
		if effect_tween and effect_tween.is_running() and not dialogue.effect.is_empty():
			effect_tween.kill()
			persistent_effect_running = false
		
		if dialogue.effect_sound:
			shake_audio.stream = dialogue.effect_sound
			shake_audio.play()
		
		for ef in dialogue.effect:
			var box = container
			var ox = box.position.x
			var oy = box.position.y
			
			if ef is ShakeEffect:
				var sh = ef as ShakeEffect
				effect_tween = get_tree().create_tween()
				for i in sh.count:
					var shake_sign = 1 if i % 2 == 0 else -1
					effect_tween.tween_property(box, "position:x", ox + sh.magnitude_x * shake_sign, sh.speed)
					effect_tween.tween_property(box, "position:y", oy + sh.magnitude_y * shake_sign, sh.speed)
				effect_tween.tween_property(box, "position:x", ox, sh.speed)
				effect_tween.tween_property(box, "position:y", oy, sh.speed)
			elif ef is WobbleEffect:
				var wo = ef as WobbleEffect
				persistent_effect_running = dialogue.persist_effects
				container.pivot_offset = dialogue_box.position + dialogue_box.size / 2.0
				effect_tween = get_tree().create_tween()
				for i in wo.count:
					var amplitude = wo.rotation * pow(wo.decay, i)
					if amplitude < wo.snap_threshold:
						break
					var wob_sign = 1 if i % 2 == 0 else -1
					effect_tween.tween_property(container, "rotation_degrees", amplitude * wob_sign, wo.speed) \
						.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
				effect_tween.tween_callback(func():
					if wo.fierce_return:
						var st = get_tree().create_tween()
						st.set_ease(Tween.EASE_OUT)
						st.set_trans(Tween.TRANS_ELASTIC)
						st.tween_property(container, "position:x", 0.0, 0.5)
						st.parallel().tween_property(container, "position:y", 0.0, 0.5)
						st.parallel().tween_property(container, "rotation_degrees", 0.0, 0.5)
					else:
						var st = get_tree().create_tween()
						st.set_ease(Tween.EASE_OUT)
						st.set_trans(Tween.TRANS_SINE)
						st.tween_property(container, "rotation_degrees", 0.0, wo.speed * 1.5)
				)
		
		typing_tween = get_tree().create_tween()
		text_box.text = ""
		text_box.add_theme_color_override("font_color", dialogue.text_color)
		text_box.add_theme_font_override("font", dialogue.text_font)
		for character in processed_content:
			typing_tween.tween_callback(append_character.bind(character)).set_delay(dialogue.typing_speed)
			if character in [".", "!", "?", "。", "！", "？"]:
				typing_tween.tween_interval(0.4)
			elif character in [",", "，", ";", "；", ":", "："]:
				typing_tween.tween_interval(0.15)
		typing_tween.tween_callback(func():
			dialogue_index += 1
			end_hint.modulate.a = 1.0
			blink_tween = get_tree().create_tween().set_loops()
			blink_tween.tween_property(end_hint, "modulate:a", 0.2, 0.4)
			blink_tween.tween_property(end_hint, "modulate:a", 1.0, 0.4)
		)
		
		if dialogue.show_on_left:
			left_avatar.texture = dialogue.avatar
			right_avatar.texture = null
		else:
			right_avatar.texture = dialogue.avatar
			left_avatar.texture = null
			
	#
#func _finish_dialogue() -> void:
	#persistent_effect_running = false
	#container.position = Vector2.ZERO
	#container.rotation_degrees = 0.0
	#Global.set_flag(main_dialogue.set_flag)
	#Global.dialogue_broadcast.emit(main_dialogue.next_id)
	#Global.can_act = true
	#visible = false
	#dialogue_finished.emit()

func _finish_dialogue(skip_broadcast: bool = false) -> void:
	persistent_effect_running = false
	container.position = Vector2.ZERO
	container.rotation_degrees = 0.0
	Global.set_flag(main_dialogue.set_flag)
	if not skip_broadcast:
		Global.dialogue_broadcast.emit(main_dialogue.next_id)
	Global.can_act = true
	visible = false
	dialogue_finished.emit()
func _show_choices(group: DialogueGroup) -> void:
	text_box.text = ""
	choices_active = true
	for i in choice_buttons.size():
		if i < group.choices.size() and group.choices[i] != "":
			choice_buttons[i].text = group.choices[i]
			choice_buttons[i].visible = true
		else:
			choice_buttons[i].visible = false

func _hide_choices() -> void:
	for btn in choice_buttons:
		btn.visible = false
func _on_choice_pressed(index: int) -> void:
	_hide_choices()
	choices_active = false
	var group := main_dialogue
	Global.set_flag(group.set_flag)
	if index < group.choice_next_ids.size() and group.choice_next_ids[index] != "":
		Global.dialogue_broadcast.emit(group.choice_next_ids[index])
	dialogue_continue.emit()
#func _on_choice_pressed(index: int) -> void:
	#_hide_choices()
	#choices_active = false
	#var group := main_dialogue
	#Global.set_flag(group.set_flag)
	#var next_id_to_broadcast := ""
	#if index < group.choice_next_ids.size():
		#next_id_to_broadcast = group.choice_next_ids[index]
	#if next_id_to_broadcast != "":
		#Global.dialogue_broadcast.emit(next_id_to_broadcast)
	#
	#_finish_dialogue(true)
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
	for btn in choice_buttons:
		btn.visible = false
		btn.pressed.connect(_on_choice_pressed.bind(choice_buttons.find(btn)))
	
func start_dialogue(group: DialogueGroup) -> void:
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
	typing_tween = null
	if effect_tween and effect_tween.is_running():
		effect_tween.kill()
	if blink_tween and blink_tween.is_running():
		blink_tween.kill()
	persistent_effect_running = false
	container.position = Vector2.ZERO
	container.rotation_degrees = 0.0
	main_dialogue = group
	dialogue_index = 0
	visible = true
	Global.can_act = false
	display_next_dialogue()

















func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if choices_active:
		return
	if event.is_action_pressed("interact"):
		display_next_dialogue()
	

#kkk



		
