class_name GameCam extends Camera2D

@export var randomStrength := 7.0
@export var shakeFade := 10.0

var rng = RandomNumberGenerator.new()

var shake_strength := 0.0

func _ready() -> void:
	Globals.camera = self

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade*delta)
		
		offset = random_offset()

func apply_shake():
	shake_strength = randomStrength

func random_offset():
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
