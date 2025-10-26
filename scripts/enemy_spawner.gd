extends Node2D

var time_left = 2.5
var enemy = preload("res://scenes/enemy_one.tscn")

func _process(delta: float) -> void:
	time_left -= delta
	if time_left <= 0:
		var b = enemy.instantiate()
		get_tree().root.add_child(b)
		b.global_position = Vector2(randi_range(-100, 1300), randi_range(70, 800))
		time_left = 2.5
