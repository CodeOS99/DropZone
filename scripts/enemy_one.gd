extends CharacterBody2D

const SPEED := 75.0
const COOLDOWN := 0.5

var piece_idx: int = -1
var tile_displ_idx: int = -1
var tile_displ: Vector2i
var target_pos: Vector2

var cooldown_left: float = 0.0

func _ready() -> void:
	update_target()

func _process(delta: float) -> void:
	if Globals.tetris == null:
		return
	
	# If the current piece changed, pick a new target
	if piece_idx != Globals.tetris.curr_piece_idx:
		update_target()
	
	var piece = Globals.tetris.pieces[piece_idx]
	var tetro_key = piece[0]
	var world_tile_pos = Globals.tetris.to_global(Globals.tetris.map_to_local(piece[1] + tile_displ))
	
	# Move towards the target
	velocity = (world_tile_pos - global_position).normalized() * SPEED
	move_and_slide()
	
	if global_position.distance_to(world_tile_pos) < 10 and cooldown_left <= 0:
		attack_piece_tile(piece, tetro_key)
		cooldown_left = COOLDOWN
	
	cooldown_left = max(0, cooldown_left - delta)


func attack_piece_tile(piece, tetro_key):
	var tile_ref = Globals.tetris.TETROMINOES[tetro_key][tile_displ_idx]
	var hit_array = piece[4]
	
	if hit_array.has(tile_ref):
		hit_array[tile_ref] += 1
		if hit_array[tile_ref] > 3:
			piece[3].append(tile_ref)
	else:
		hit_array[tile_ref] = 1


func update_target():
	piece_idx = Globals.tetris.curr_piece_idx
	var piece = Globals.tetris.pieces[piece_idx]
	
	var tetro_key = piece[0]
	var tetro_tiles = Globals.tetris.TETROMINOES[tetro_key]
	
	tile_displ_idx = randi_range(0, tetro_tiles.size() - 1)
	tile_displ = tetro_tiles[tile_displ_idx]
	
	var local_tile_pos = piece[1] + tile_displ
	target_pos = Globals.tetris.to_global(Globals.tetris.map_to_local(local_tile_pos))
