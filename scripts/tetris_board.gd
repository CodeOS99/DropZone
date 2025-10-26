class_name Tetris extends TileMapLayer

const TILE_COLORS = 8
const DEFAULT_TILE = 7
const TICK_TIME = .8
const TETROMINOES = {
	# I piece (pivot at (1.5,1.5))
	"I_0": [Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1)],
	"I_1": [Vector2i(2,0), Vector2i(2,1), Vector2i(2,2), Vector2i(2,3)],
	"I_2": [Vector2i(3,2), Vector2i(2,2), Vector2i(1,2), Vector2i(0,2)],
	"I_3": [Vector2i(1,3), Vector2i(1,2), Vector2i(1,1), Vector2i(1,0)],

	# O piece — no rotation change, but still same-index correspondence
	"O_0": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
	"O_1": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
	"O_2": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
	"O_3": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],

	# T piece (pivot at (1,1))
	"T_0": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
	"T_1": [Vector2i(2,1), Vector2i(1,0), Vector2i(1,1), Vector2i(1,2)],
	"T_2": [Vector2i(1,2), Vector2i(2,1), Vector2i(1,1), Vector2i(0,1)],
	"T_3": [Vector2i(0,1), Vector2i(1,2), Vector2i(1,1), Vector2i(1,0)],

	# S piece (pivot at (1,1))
	"S_0": [Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1)],
	"S_1": [Vector2i(2,1), Vector2i(2,2), Vector2i(1,0), Vector2i(1,1)],
	"S_2": [Vector2i(1,2), Vector2i(0,2), Vector2i(2,1), Vector2i(1,1)],
	"S_3": [Vector2i(0,1), Vector2i(0,0), Vector2i(1,2), Vector2i(1,1)],

	# Z piece (pivot at (1,1))
	"Z_0": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)],
	"Z_1": [Vector2i(2,0), Vector2i(2,1), Vector2i(1,1), Vector2i(1,2)],
	"Z_2": [Vector2i(2,2), Vector2i(1,2), Vector2i(1,1), Vector2i(0,1)],
	"Z_3": [Vector2i(0,2), Vector2i(0,1), Vector2i(1,1), Vector2i(1,0)],

	# J piece (pivot at (1,1))
	"J_0": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
	"J_1": [Vector2i(1,0), Vector2i(2,0), Vector2i(1,1), Vector2i(1,2)],
	"J_2": [Vector2i(2,2), Vector2i(2,1), Vector2i(1,1), Vector2i(0,1)],
	"J_3": [Vector2i(1,2), Vector2i(0,2), Vector2i(1,1), Vector2i(1,0)],

	# L piece (pivot at (1,1))
	"L_0": [Vector2i(2,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
	"L_1": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(2,2)],
	"L_2": [Vector2i(0,2), Vector2i(2,1), Vector2i(1,1), Vector2i(0,1)],
	"L_3": [Vector2i(1,2), Vector2i(1,1), Vector2i(1,0), Vector2i(0,0)],
}

var size = Vector2i(12, 25)

var board = [] # [coord_x, alt] coord_x controls color and alt controls health

var timer := 0.0

var pieces = [] # [tetromino, coord, tile-idx, removed_indices, {ith-vertex: hits-taken_ith-vertex+1}]
var curr_piece_idx = -1 # the one which is being controlled right now

func _ready() -> void:
	Globals.tetris = self
	
	# initializatoin first to make testing easy
	while len(board) < size.y:
		board.append([])
	for i in range(size.y):
		while len(board[i]) < size.x:
			board[i].append([DEFAULT_TILE, 1])
	
	spawn_new_piece()
	update_board()
	draw_board()

func _process(delta: float) -> void:
	if not Globals.tetris_mode:
		timer += delta
		if timer >= TICK_TIME:
			timer = 0
			update_board()
			draw_board()
		return

	timer += delta * (10 if Input.is_action_pressed("down") else 1)
	if timer >= TICK_TIME:
		timer = 0
		update_board()
		draw_board()
	
	var hor_movement = (1 if Input.is_action_just_pressed("right") else -1 if Input.is_action_just_pressed("left") else 0)
	move_if_possible(pieces[curr_piece_idx], Vector2i(hor_movement, 0))
	
	if Input.is_action_just_pressed("rotate_clock") or Input.is_action_just_pressed("rotate_anticlock"):
		var piece = pieces[curr_piece_idx]
		var old_rot_str = piece[0] 
		var delta_ = 1 if Input.is_action_just_pressed("rotate_clock") else 3
		var new_rot_str = rotation_string_for(old_rot_str, delta_)

		var candidate = piece.duplicate()
		candidate[0] = new_rot_str

		if is_valid(piece, candidate):
			for i in range(len(TETROMINOES[old_rot_str])):
				if i in piece[3]:
					continue
				var old_disp = TETROMINOES[old_rot_str][i]
				var abs_old = old_disp + piece[1]
				board[abs_old.y][abs_old.x][0] = DEFAULT_TILE
				board[abs_old.y][abs_old.x][1] = 1

			# update rotation string
			pieces[curr_piece_idx][0] = new_rot_str

			# place blocks at new rotation positions and restore per index health
			for i in range(len(TETROMINOES[new_rot_str])):
				if i in piece[3]:
					continue
				var new_disp = TETROMINOES[new_rot_str][i]
				var abs_new = new_disp + piece[1]
				board[abs_new.y][abs_new.x][0] = piece[2]
				board[abs_new.y][abs_new.x][1] = piece[4][i]

func rotation_string_for(piece_string, delta_rot):
	var base = piece_string.substr(0, 2)   # "T_"
	var rot = int(piece_string.get_slice("_", 1))
	var new_rot = (rot + delta_rot) % 4
	return base + str(new_rot)

func is_valid(piece, candidate):
	for i in range(len(TETROMINOES[candidate[0]])):
		if i in piece[3]:
			continue
		
		var vertex = TETROMINOES[candidate[0]][i]
		var abs_pos = vertex + candidate[1]
		
		if abs_pos.y >= size.y or abs_pos.x < 0 or abs_pos.x >= size.x:
			return false
		
		if board[abs_pos.y][abs_pos.x][0] != DEFAULT_TILE:
			var is_current_piece_block = false
			for j in range(len(TETROMINOES[piece[0]])):
				if j in piece[3]:
					continue
				var piece_vertex = TETROMINOES[piece[0]][j]
				var piece_abs_pos = piece_vertex + piece[1]
				if piece_abs_pos == abs_pos:
					is_current_piece_block = true
					break
			
			if not is_current_piece_block:
				return false
	
	return true

func draw_board() -> void:
	for i in range(size.y):
		for j in range(size.x):
			set_cell(Vector2i(j, i), 0, Vector2i(board[i][j][0], 0), board[i][j][1])

func update_board() -> void:
	var gone_through_active = false
	for piece_idx in range(len(pieces)):
		if not move_if_possible(pieces[piece_idx], Vector2(0, 1)) and piece_idx == curr_piece_idx and not gone_through_active:
			spawn_new_piece()
			gone_through_active = true
	if len(TETROMINOES[pieces[curr_piece_idx][0]]) == len(pieces[curr_piece_idx][3]):
		spawn_new_piece()
	
	check_for_row()

func move_if_possible(piece, displ: Vector2i):
	if displ == Vector2i.ZERO:
		return true
	
	var candidate = piece.duplicate()
	candidate[1] += displ
	
	if not is_valid(piece, candidate):
		return false
	
	for i in range(len(TETROMINOES[piece[0]])):
		if i in piece[3]:  # Check index instead of position
			continue
		var vertex_displ = TETROMINOES[piece[0]][i]
		var old_coord = vertex_displ + piece[1]
		board[old_coord.y][old_coord.x] = [DEFAULT_TILE, 1]
	
	piece[1] += displ
	
	for i in range(len(TETROMINOES[piece[0]])):
		if i in piece[3]:
			continue
		var vertex_displ = TETROMINOES[piece[0]][i]
		var new_coord = vertex_displ + piece[1]
		board[new_coord.y][new_coord.x][0] = piece[2]
		board[new_coord.y][new_coord.x][1] = piece[4][i]
	
	draw_board()
	return true

func check_for_row():
	var flag
	var how_many = 0 # how many rows are cleared in a streak
	for i in range(size.y):
		flag = true
		for j in range(size.x):
			if board[i][j][0] == DEFAULT_TILE:
				flag = false
			
			# don't use the currently active piece
			for vertex_idx in range(len(TETROMINOES[pieces[curr_piece_idx][0]])):
				if vertex_idx in pieces[curr_piece_idx][3]:
					continue
				var vertex_displ = TETROMINOES[pieces[curr_piece_idx][0]][vertex_idx]
				if Vector2i(j, i) == pieces[curr_piece_idx][1] + vertex_displ:
					flag = false
					break
		
		if flag:
			how_many += 1
			# move every piece above this one down and in the row, make it blank
			for piece in pieces:
				for vertex_idx in range(len(TETROMINOES[piece[0]])):
					if vertex_idx in piece[3]:
						continue
					var vertex_displ = TETROMINOES[piece[0]][vertex_idx]
					if (vertex_displ+piece[1]).y == i:
						piece[3].append(vertex_idx)
						board[(vertex_displ+piece[1]).y][(vertex_displ+piece[1]).x][0] = DEFAULT_TILE
					if (vertex_displ+piece[1]).y <= i:
						piece[1].y += 1
			board.remove_at(i)
			var x = []
			for j in range(size.x):
				x.append([DEFAULT_TILE, 1])
			board.push_front(x)
	
	if how_many > 0:
		var score_gain
		
		match how_many:
			1: score_gain = 100
			2: score_gain = 300
			3: score_gain = 500
			4: score_gain = 800
		Globals.score += score_gain

func spawn_new_piece():
	curr_piece_idx += 1
	var piece = ['I_0', 'O_0', 'T_0', 'S_0', 'Z_0', 'J_0', 'L_0'].pick_random() # idc if theres a better way to do this
	#var piece = ['I_0', 'O_0'].pick_random()
	var pos = Vector2i(randi_range(1, size.x-3), 2)
	var idx = randi_range(0, TILE_COLORS-2)

	var hit_array = [1, 1, 1, 1]

	pieces.append([piece, pos, idx, [], hit_array])

func get_random_piece_idx(): # used by enemy
	return randi_range(0, len(pieces)-1)
