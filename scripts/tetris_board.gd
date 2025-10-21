extends TileMapLayer

const TILE_COLORS = 8
const DEFAULT_TILE = 7
const TICK_TIME = .1

var size = Vector2i(10, 25)

# Left L shape at first
var board = [[1,1,1],
			 [1]]

var timer := 0.0

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
	for i in range(size.y):
		for j in range(size.x):
			set_cell(Vector2i(j, i), 0, Vector2i(board[i][j], 0))

func update_board() -> void:
	var new_board = board.duplicate(true)
	for i in range(size.y-2, -1, -1):
		for j in range(size.x, -1, -1):
			if board[i][j] != DEFAULT_TILE:
				new_board[i+1][j] = board[i][j]
				new_board[i][j] = DEFAULT_TILE
	
	board = new_board
