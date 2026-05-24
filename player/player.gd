extends CharacterBody2D


@onready var ray_cast_2d: RayCast2D = $Raycast2D

var last_direction := Vector2.RIGHT
var ray_length: int = 45

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	if not Global.can_act:
		return
	
	var input_dir :=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if input_dir != Vector2.ZERO:
		last_direction = input_dir
		ray_cast_2d.target_position = input_dir * ray_length
	
	var direction_x := Input.get_axis("ui_left", "ui_right")
	var direction_y := Input.get_axis("ui_up", "ui_down")
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y,0,SPEED)
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if not Global.can_act :
		return
	if event.is_action_pressed("interact"):
		print("act!")
		if ray_cast_2d.is_colliding():
			var target =ray_cast_2d.get_collider()
			if target.has_method("interact"):
				target.interact()
				get_viewport().set_input_as_handled()


	










#
