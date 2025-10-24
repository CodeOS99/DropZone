class_name Tetris extends TileMapLayer

const TILE_COLORS = 8
const DEFAULT_TILE = 7
const TICK_TIME = .8
const TETROMINOES = {
	# I piece (straight line)
	"I_0": [Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1)],
	"I_1": [Vector2i(2,0), Vector2i(2,1), Vector2i(2,2), Vector2i(2,3)],
	"I_2": [Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2)],
	"I_3": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(1,3)],

	# O piece (square) — no rotation changes
	"O_0": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
	"O_1": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
	"O_2": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
	"O_3": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],

	# T piece
	"T_0": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
	"T_1": [Vector2i(1,0), Vector2i(1,1), Vector2i(2,1), Vector2i(1,2)],
	"T_2": [Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(1,2)],
	"T_3": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(1,2)],

	# S piece
	"S_0": [Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1)],
	"S_1": [Vector2i(1,0), Vector2i(1,1), Vector2i(2,1), Vector2i(2,2)],
	"S_2": [Vector2i(1,1), Vector2i(2,1), Vector2i(0,2), Vector2i(1,2)],
	"S_3": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(1,2)],

	# Z piece
	"Z_0": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)],
	"Z_1": [Vector2i(2,0), Vector2i(2,1), Vector2i(1,1), Vector2i(1,2)],
	"Z_2": [Vector2i(0,1), Vector2i(1,1), Vector2i(1,2), Vector2i(2,2)],
	"Z_3": [Vector2i(1,0), Vector2i(1,1), Vector2i(0,1), Vector2i(0,2)],

	# J piece
	"J_0": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
	"J_1": [Vector2i(1,0), Vector2i(2,0), Vector2i(1,1), Vector2i(1,2)],
	"J_2": [Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(2,2)],
	"J_3": [Vector2i(1,0), Vector2i(1,1), Vector2i(0,2), Vector2i(1,2)],

	# L piece
	"L_0": [Vector2i(2,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
	"L_1": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(2,2)],
	"L_2": [Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(0,2)],
	"L_3": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(1,2)],
}

var size = Vector2i(12, 25)

var board = [] # array of arrays of [coord_x, alt] coord_x controls color and alt controls health

var timer := 0.0

var pieces = [] # array of [tetromino, coord, tile-idx, removed, {ith-vertex: hits-taken_ith-vertex+1}]
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
	
	if Input.is_action_just_pressed("rotate_clock"):
		var piece = pieces[curr_piece_idx]
		var flag = false
		var candidate = piece.duplicate()
		candidate[0] = piece[0][0] + piece[0][1] + str((int(piece[0][2])+1)%4)
		if is_valid(piece, candidate):
			for vertex_displ in TETROMINOES[pieces[curr_piece_idx][0]]:
				board[(vertex_displ+pieces[curr_piece_idx][1]).y][(vertex_displ+pieces[curr_piece_idx][1]).x][0] = DEFAULT_TILE
			pieces[curr_piece_idx][0] = pieces[curr_piece_idx][0][0] + pieces[curr_piece_idx][0][1] + str((int(pieces[curr_piece_idx][0][2])+1)%4)
			for vertex_displ in TETROMINOES[pieces[curr_piece_idx][0]]:
				board[(vertex_displ+pieces[curr_piece_idx][1]).y][(vertex_displ+pieces[curr_piece_idx][1]).x][0] = pieces[curr_piece_idx][2]
				
	if Input.is_action_just_pressed("rotate_anticlock"):
		var piece = pieces[curr_piece_idx]
		var flag = false
		var candidate = piece.duplicate()
		candidate[0] = piece[0][0] + piece[0][1] + str((int(piece[0][2])+3)%4)
		if is_valid(piece, candidate):
			for vertex_displ in TETROMINOES[pieces[curr_piece_idx][0]]:
				board[(vertex_displ+pieces[curr_piece_idx][1]).y][(vertex_displ+pieces[curr_piece_idx][1]).x][0] = DEFAULT_TILE
			pieces[curr_piece_idx][0] = pieces[curr_piece_idx][0][0] + pieces[curr_piece_idx][0][1] + str((int(pieces[curr_piece_idx][0][2])+3)%4)
			for vertex_displ in TETROMINOES[pieces[curr_piece_idx][0]]:
				board[(vertex_displ+pieces[curr_piece_idx][1]).y][(vertex_displ+pieces[curr_piece_idx][1]).x][0] = pieces[curr_piece_idx][2]

func is_valid(piece, candidate):
	var flag = false
	for vertex in TETROMINOES[candidate[0]]:
		if vertex+piece[1] in piece[3]:
			continue
		
		# checks if in range
		if (vertex+candidate[1]).y >= size.y or not (vertex+candidate[1]).x in range(0, size.x):
			flag = true
		# checks if empty
		elif board[(vertex+candidate[1]).y][(vertex+candidate[1]).x][0] != DEFAULT_TILE:
			# I did a huge overhaul of the logic to draw but then it broke this part and i dont want to go back so im doing this :\
			var flag2 = false
			for vertex_displ in TETROMINOES[piece[0]]:
				var v = vertex_displ + piece[1]
				if v == vertex + candidate[1]:
					flag2 = true
			
			if not flag2:
				flag = true
	return not flag

func draw_board() -> void:
	# reset
	for i in range(size.y):
		for j in range(size.x):
			set_cell(Vector2i(j, i), 0, Vector2i(board[i][j][0], 0), board[i][j][1])

func update_board() -> void:
	var gone_through_active = false
	for piece_idx in range(len(pieces)):
		if not move_if_possible(pieces[piece_idx], Vector2(0, 1)) and piece_idx == curr_piece_idx and not gone_through_active:
			spawn_new_piece()
			gone_through_active = true
	
	check_for_row()

func move_if_possible(piece, displ: Vector2i):
	if displ == Vector2i.ZERO:
		return true
	var flag = false
	var candidate = piece.duplicate()
	candidate[1] += displ
	for vertex in TETROMINOES[piece[0]]:
		if vertex+piece[1] in piece[3]:
			flag = true
			continue
		
		# checks if in range
		if (vertex+candidate[1]).y >= size.y or not (vertex+candidate[1]).x in range(0, size.x):
			flag = true
		# checks if empty
		elif board[(vertex+candidate[1]).y][(vertex+candidate[1]).x][0] != DEFAULT_TILE:
			# I did a huge overhaul of the logic to draw but then it broke this part and i dont want to go back so im doing this :\
			var flag2 = false
			for vertex_displ in TETROMINOES[piece[0]]:
				var v = vertex_displ + piece[1]
				if v == vertex + candidate[1]:
					flag2 = true
			
			if not flag2:
				flag = true
	
	if not flag:
		# reset
		for vertex_displ in TETROMINOES[piece[0]]:
			var coord = vertex_displ + piece[1]
			board[coord.y][coord.x] = [DEFAULT_TILE, 1]
		
		piece[1] += displ # change pos
		
		# new pos
		for vertex_displ_idx in range(len(TETROMINOES[piece[0]])):
			var vertex_displ = TETROMINOES[piece[0]][vertex_displ_idx]
			if vertex_displ in piece[3]:
				continue
			var coord = vertex_displ + piece[1]
			board[coord.y][coord.x][0] = piece[2]
			board[coord.y][coord.x][1] = piece[4][vertex_displ]
			
		draw_board()
		return true

	return false

func check_for_row():
	var flag
	var how_many = 0 # how many rows are cleared in a streak
	for i in range(size.y):
		flag = true
		for j in range(size.x):
			if board[i][j][0] == DEFAULT_TILE:
				flag = false
			
			# dont use the currently active piece
			for vertex_displ in TETROMINOES[pieces[curr_piece_idx][0]]:
				if Vector2i(j, i) == pieces[curr_piece_idx][1] + vertex_displ:
					flag = false
					break
		
		if flag:
			how_many += 1
			# move every piece above this one down and in the row, make it blank
			for piece in pieces:
				for vertex_displ in TETROMINOES[piece[0]]:
					if (vertex_displ+piece[1]).y == i:
						piece[3].append(vertex_displ+piece[1])
						board[(vertex_displ+piece[1]).y][(vertex_displ+piece[1]).x][0] = DEFAULT_TILE
					if (vertex_displ+piece[1]).y <= i:
						piece[1].y += 1
			board.remove_at(i)
			var x = []
			for j in range(size.x):
				x.append([DEFAULT_TILE, 1])
			board.push_front(x)
		else:
			if how_many > 0:
				print(how_many)
			how_many = 0

func spawn_new_piece():
	curr_piece_idx += 1
	#var piece = ['I_0', 'O_0', 'T_0', 'S_0', 'Z_0', 'J_0', 'L_0'].pick_random() # idc if theres a better way to do this
	var piece = ['I_0', 'O_0'].pick_random()
	var pos = Vector2i(randi_range(1, size.x-3), 2)
	var idx = randi_range(0, TILE_COLORS-2)
	var hit_array = {}
	for i in TETROMINOES[piece]:
		hit_array[i] = 1
	pieces.append([piece, pos, idx, [], hit_array])

func get_random_piece_idx(): # used by enemy
	return randi_range(0, len(pieces)-1)
