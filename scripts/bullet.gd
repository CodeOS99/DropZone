extends CharacterBody2D

const SPEED = 250

var life_rem = 7.5

var explosion_particles = preload('res://scenes/explosion.tscn')

func _physics_process(delta: float) -> void:
	velocity = Vector2(cos(rotation-PI/2), sin(rotation-PI/2)) * SPEED
	
	move_and_slide()
	life_rem -= delta
	
	if life_rem <= 0:
		queue_redraw()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		var p = explosion_particles.instantiate()
		get_tree().root.add_child(p)
		p.global_position = area.get_parent().global_position
		p.emitting = true
		area.get_parent().queue_free()
