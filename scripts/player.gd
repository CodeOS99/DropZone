extends CharacterBody2D

const SPEED = 300.0

var bullet = preload("res://scenes/bullet.tscn")
@onready var shoot_point = $ShootPoint

func _physics_process(delta: float) -> void:
	if Globals.tetris_mode:
		return
	
	look_at(get_viewport().get_mouse_position())
	rotation += PI/2
	
	if Input.is_action_just_pressed("shoot"):
		var b = bullet.instantiate()
		get_tree().root.add_child(b)
		b.global_position = shoot_point.global_position
		b.rotation = self.rotation

	var directions = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	velocity = directions * SPEED
	
	if directions != Vector2.ZERO:
		$Footsteps.visible = true
	else:
		$Footsteps.visible = false
		$Footsteps.restart()

	move_and_slide()
