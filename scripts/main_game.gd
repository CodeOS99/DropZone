extends Node2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_mode"):
		Globals.tetris_mode = not Globals.tetris_mode
		print(":D")
