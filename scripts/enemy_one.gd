extends CharacterBody2D

const SPEED := 75.0
const COOLDOWN := 0.5

var piece_idx: int = -1
var tile_displ_idx: int = -1
var tile_displ: Vector2i
var target_pos: Vector2
var cooldown_left: float = 0.0
var last_tetro_key: String = ""

func _ready() -> void:
	update_target()

func _process(delta: float) -> void:
	if Globals.tetris == null:
		return
	
	if piece_idx != Globals.tetris.curr_piece_idx:
		update_target()
		return
	
	var piece = Globals.tetris.pieces[piece_idx]
	var tetro_key = piece[0]
	
	if tetro_key != last_tetro_key:
		update_target()
		return
	
	var tetro_tiles = Globals.tetris.TETROMINOES[tetro_key]
	
	if tile_displ_idx >= tetro_tiles.size():
		update_target()
		return
	
	tile_displ = tetro_tiles[tile_displ_idx]
	
	if tile_displ_idx in piece[3]:
		update_target()
		return
	
	var world_tile_pos = Globals.tetris.to_global(
		Globals.tetris.map_to_local(piece[1] + tile_displ)
	)
	
	velocity = (world_tile_pos - global_position).normalized() * SPEED
	move_and_slide()
	
	if global_position.distance_to(world_tile_pos) < 10 and cooldown_left <= 0:
		attack_piece_tile(piece)
		cooldown_left = COOLDOWN
	
	cooldown_left = max(0, cooldown_left - delta)

func attack_piece_tile(piece):
	var hit_array: Array = piece[4]
	
	if tile_displ_idx >= 0 and tile_displ_idx < hit_array.size():
		hit_array[tile_displ_idx] += 1
		Globals.score = max(Globals.score-10, 0)
		
		if hit_array[tile_displ_idx] > 3:
			piece[3].append(tile_displ_idx)
			
			var absolute_pos = piece[1] + tile_displ
			Globals.tetris.board[absolute_pos.y][absolute_pos.x][0] = Globals.tetris.DEFAULT_TILE
			Globals.tetris.board[absolute_pos.y][absolute_pos.x][1] = 1
			
			Globals.tetris.draw_board()
			update_target()

func update_target():
	if Globals.tetris == null:
		return
	
	piece_idx = Globals.tetris.curr_piece_idx
	
	if piece_idx < 0 or piece_idx >= Globals.tetris.pieces.size():
		return
	
	var piece = Globals.tetris.pieces[piece_idx]
	var tetro_key = piece[0]
	last_tetro_key = tetro_key
	var tetro_tiles = Globals.tetris.TETROMINOES[tetro_key]
	
	var available_indices = []
	for i in range(tetro_tiles.size()):
		if not (i in piece[3]):
			available_indices.append(i)
	
	if available_indices.is_empty():
		tile_displ_idx = -1
		return
	
	tile_displ_idx = available_indices.pick_random()
	tile_displ = tetro_tiles[tile_displ_idx]
	
	var local_tile_pos = piece[1] + tile_displ
	target_pos = Globals.tetris.to_global(
		Globals.tetris.map_to_local(local_tile_pos)
	)
