extends CharacterBody2D

const SPEED = 75
const COOLDOWN: float = 1.0

var piece_idx: int # index of the piece in the tetris board
var tile_displ: Vector2i # the displacement of the tile which is target(rel. to the piece, this is not the index)

var target_pos: Vector2

var cooldown_left: float = 0.0

func _ready() -> void:
	set_target()

func _process(delta: float) -> void:
	velocity = (target_pos-global_position).normalized() * SPEED
	move_and_slide()
	update_target()
	
	if should_get_new_target():
		set_target()
	
	var tolerance = 10
	if global_position.distance_to(target_pos) <= tolerance and cooldown_left <= 0:
		var piece = Globals.tetris.pieces[piece_idx]
		if piece[4][tile_displ] <= 3:
			piece[4][tile_displ] += 1
		else:
			piece[3].append(tile_displ)
		cooldown_left = COOLDOWN
	
	cooldown_left -= delta

func should_get_new_target():
	var piece = Globals.tetris.pieces[piece_idx]
	
	if tile_displ in piece[3]:
		return true

func set_target():
	piece_idx = Globals.tetris.get_random_piece_idx()
	var piece = Globals.tetris.pieces[piece_idx]
	tile_displ = (Globals.tetris.TETROMINOES[piece[0]]).pick_random()
	target_pos = Globals.tetris.to_global(Globals.tetris.map_to_local(piece[1] + tile_displ))
	print(target_pos)

func update_target():
	var piece = Globals.tetris.pieces[piece_idx]
	target_pos = Globals.tetris.to_global(Globals.tetris.map_to_local(piece[1] + tile_displ))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("TetrisBoard"):
		pass
