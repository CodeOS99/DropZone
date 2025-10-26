extends Node2D

func _ready() -> void:
	Globals.score = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_mode"):
		Globals.tetris_mode = not Globals.tetris_mode
