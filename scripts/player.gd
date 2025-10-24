extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	if Globals.tetris_mode:
		return

	var directions = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	velocity = directions * SPEED
	
	if directions != Vector2.ZERO:
		$Footsteps.visible = true
	else:
		$Footsteps.visible = false
		$Footsteps.restart()

	move_and_slide()
