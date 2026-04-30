extends Node

const GRID_SIZE := 4
const TILE_SIZE := 120
const TILE_GAP := 10

var grid: Array = []
var score := 0

@onready var grid_container = $"../CenterContainer/Panel/MarginContainer/VBoxContainer/GridContainer"

func _ready() -> void:
	grid_container.columns = GRID_SIZE
	grid_container.add_theme_constant_override("h_separation", TILE_GAP)
	grid_container.add_theme_constant_override("v_separation", TILE_GAP)

	_init_grid()
	spawn_tile()
	spawn_tile()
	update_visuals()

func _init_grid() -> void:
	grid.clear()

	for row in range(GRID_SIZE):
		grid.append([])
		for col in range(GRID_SIZE):
			grid[row].append(0)

			var cell = ColorRect.new()
			cell.custom_minimum_size = Vector2(TILE_SIZE, TILE_SIZE)
			cell.color = Color("#EEF0EB")

			var label = Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.set_anchors_preset(Control.PRESET_FULL_RECT)
			label.text = ""
			label.add_theme_font_size_override("font_size", 48)

			cell.add_child(label)
			grid_container.add_child(cell)

func spawn_tile() -> void:
	var empty_cells: Array = []

	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if grid[row][col] == 0:
				empty_cells.append(Vector2i(row, col))

	if empty_cells.is_empty():
		return

	var random_cell = empty_cells[randi() % empty_cells.size()]
	grid[random_cell.x][random_cell.y] = 4 if randf() > 0.9 else 2

func update_visuals() -> void:
	var cells = grid_container.get_children()

	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var index = row * GRID_SIZE + col
			var cell = cells[index]
			var value = grid[row][col]
			var label: Label = cell.get_child(0)

			if value == 0:
				cell.color = Color("#EEF0EB")
				label.text = ""
			else:
				cell.color = get_tile_color(value)
				label.text = str(value)

			if value <= 4:
				label.add_theme_color_override("font_color", Color("776e65"))
			else:
				label.add_theme_color_override("font_color", Color("ffffff"))

func check_win() -> bool:
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if grid[row][col] == 2048:
				return true
	return false

func is_game_over() -> bool:
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if grid[row][col] == 0:
				return false

	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if col + 1 < GRID_SIZE and grid[row][col] == grid[row][col + 1]:
				return false
			if row + 1 < GRID_SIZE and grid[row][col] == grid[row + 1][col]:
				return false

	return true

func get_highest_tile() -> int:
	var highest := 0

	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			highest = max(highest, grid[row][col])

	return highest

func get_tile_color(value: int) -> Color:
	match value:
		2:    return Color("ffffff")
		4:    return Color("fffde0")
		8:    return Color("ff9900")
		16:   return Color("ff6600")
		32:   return Color("ff3300")
		64:   return Color("ff0000")
		128:  return Color("ffdd00")
		256:  return Color("ffe500")
		512:  return Color("00cc44")
		1024: return Color("0099ff")
		2048: return Color("aa00ff")
		_:    return Color("000000")
