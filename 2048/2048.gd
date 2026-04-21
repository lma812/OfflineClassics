extends Node2D

const GRID_SIZE = 4
const TILE_SIZE = 120
const TILE_GAP = 10

var grid = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid = []
	for row in range(GRID_SIZE):
		grid.append([])
		for col in range(GRID_SIZE):
			grid[row].append(0)
			
	setup_visual_grid()
	spawn_tile()
	spawn_tile()
	
func setup_visual_grid():
	var gridContainer = $GridContainer
	gridContainer.columns = GRID_SIZE
	gridContainer.add_theme_constant_override("h_separation", TILE_GAP)
	gridContainer.add_theme_constant_override("v_separation", TILE_GAP)
	
	for i in range(GRID_SIZE * GRID_SIZE):
		var cell = ColorRect.new()
		cell.custom_minimum_size = Vector2(TILE_SIZE, TILE_SIZE)
		cell.color = Color("cdc1b4")
		gridContainer.add_child(cell)
		print("added cell ", i)
		
	var board_size = GRID_SIZE * TILE_SIZE + (GRID_SIZE - 1) * TILE_GAP
	$GridContainer.position = (get_viewport_rect().size - Vector2(board_size, board_size)) / 2

func spawn_tile():
	var empty_cells = []
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if grid[row][col] == 0:
				empty_cells.append(Vector2(row, col))
	
	var random_cell = empty_cells[randi() % empty_cells.size()]
	
	grid[random_cell.x][random_cell.y] = 4 if randf() > 0.8 else 2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
