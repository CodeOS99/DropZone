extends TileMapLayer

const TILE_COLORS = 8
const DEFAULT_TILE = 7
const TICK_TIME = .1
const TETROMINOES = {
	"I": [Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1)],
	"O": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
	"T": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
	"S": [Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1)],
	"Z": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)],
	"J": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
	"L": [Vector2i(2,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)],
}

var size = Vector2i(10, 25)

var board = []

var timer := 0.0

var pieces = [["L", Vector2i(2,0), 0]] # array of [tetromino, coord, tile_idx]

func _ready() -> void:
	# initializatoin first to make testing easy
	while len(board) <= size.y:
		board.append([])
	for i in range(size.y):
		while len(board[i]) <= size.x:
			board[i].append(DEFAULT_TILE)
	
	draw_board()
	update_board()
	draw_board()

func _process(delta: float) -> void:
	timer += delta
	if timer >= TICK_TIME:
		timer = 0
		update_board()
		draw_board()

func draw_board() -> void:
	# reset
	for i in range(size.y):
		for j in range(size.x):
			set_cell(Vector2i(j, i), 0, Vector2i(board[i][j], 0))
	
	# draw the actual things
	draw_pieces()

func draw_pieces():
	for piece in pieces: # [tetromino, coord, tile_idx]
		for vertex in TETROMINOES[piece[0]]: # rel. coords of tetromino:
			set_cell(vertex+piece[1], 0, Vector2i(piece[2], 0))

func update_board() -> void:
	for piece in pieces:
		var flag = false
		var candidate = piece.duplicate()
		candidate[1].y += 1
		for vertex in TETROMINOES[piece[0]]:
			if (vertex+piece[1]).y >= size.y-1:
				flag = true
		
		if not flag:
			piece[1].y += 1
