extends CharacterBody2D

const SPEED = 75

var piece_idx: int # index of the piece in the tetris board
var tile_displ: Vector2i # the displacement of the tile which is target(rel. to the piece, this is not the index)

var target_pos: Vector2

func _ready() -> void:
	set_target()

func _process(delta: float) -> void:
	velocity = (target_pos-global_position).normalized() * SPEED
	move_and_slide()
	update_target()

func set_target():
	piece_idx = Globals.tetris.get_random_piece_idx()
	var piece = Globals.tetris.pieces[piece_idx]
	tile_displ = (Globals.tetris.TETROMINOES[piece[0]]).pick_random()
	target_pos = Globals.tetris.to_global(Globals.tetris.map_to_local(piece[1] + tile_displ))
	print(target_pos)

func update_target():
	var piece = Globals.tetris.pieces[piece_idx]
	target_pos = Globals.tetris.to_global(Globals.tetris.map_to_local(piece[1] + tile_displ))
