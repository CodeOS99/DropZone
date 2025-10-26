extends Label

func _ready() -> void:
	var t = get_tree().create_tween().set_loops()
	t.tween_property(self, "scale", Vector2(1.3, 1.3), 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "scale", Vector2(1, 1), 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(delta: float) -> void:
	text = "Score: " + str(Globals.score)
