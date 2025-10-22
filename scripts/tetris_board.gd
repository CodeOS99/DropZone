extends TileMapLayer

const TILE_COLORS = 8
const DEFAULT_TILE = 7
const TICK_TIME = .8
const TETROMINOES = {
	"I": [Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1)],
	"O": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
	"T": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
	"S": [Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1)],
	"Z": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)],
	"J": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
	"L": [Vector2i(2,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
}

var size = Vector2i(12, 25)

var board = []

var timer := 0.0

var pieces = [] # array of [tetromino, coord, tile_idx, removed]
var curr_piece_idx = -1 # the one which is being controlled right now

func _ready() -> void:
	# initializatoin first to make testing easy
	while len(board) < size.y:
		board.append([])
	for i in range(size.y):
		while len(board[i]) < size.x:
			board[i].append(DEFAULT_TILE)
	
	spawn_new_piece()
	update_board()
	draw_board()

func _process(delta: float) -> void:
	timer += delta * (10 if Input.is_action_pressed("down") else 1)
	if timer >= TICK_TIME:
		timer = 0
		update_board()
		draw_board()
	
	var hor_movement = (1 if Input.is_action_just_pressed("right") else -1 if Input.is_action_just_pressed("left") else 0)
	move_if_possible(pieces[curr_piece_idx], Vector2i(hor_movement, 0))
	

func draw_board() -> void:
	# reset
	for i in range(size.y):
		for j in range(size.x):
			set_cell(Vector2i(j, i), 0, Vector2i(board[i][j], 0))

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
		elif board[(vertex+candidate[1]).y][(vertex+candidate[1]).x] != DEFAULT_TILE:
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
			board[coord.y][coord.x] = DEFAULT_TILE
		
		piece[1] += displ # change pos
		
		# new pos
		for vertex_displ in TETROMINOES[piece[0]]:
			if vertex_displ in piece[3]:
				continue
			var coord = vertex_displ + piece[1]
			board[coord.y][coord.x] = piece[2]
			
		draw_board()
		return true

	return false

func check_for_row():
	var flag
	var how_many = 0 # how many rows are cleared in a streak
	for i in range(size.y):
		flag = true
		for j in board[i]:
			if j == DEFAULT_TILE:
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
						board[(vertex_displ+piece[1]).y][(vertex_displ+piece[1]).x] = DEFAULT_TILE
					if (vertex_displ+piece[1]).y <= i:
						piece[1].y += 1
			board.remove_at(i)
			var x = []
			for j in range(size.x):
				x.append(DEFAULT_TILE)
			board.push_front(x)
		else:
			if how_many > 0:
				print(how_many)
			how_many = 0

func spawn_new_piece():
	curr_piece_idx += 1
	#var piece = ['I', 'O', 'T', 'S', 'Z', 'J', 'L'].pick_random() # idc if theres a better way to do this
	var piece = ['I', 'O'].pick_random()
	var pos = Vector2i(randi_range(1, size.x-3), 2)
	var idx = randi_range(0, TILE_COLORS-2)
	pieces.append([piece, pos, idx, []])
