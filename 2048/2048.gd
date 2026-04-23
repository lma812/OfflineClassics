extends Node2D

const GRID_SIZE = 4
const TILE_SIZE = 120
const TILE_GAP = 10

var grid = []
var touch_start = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid = []
	for row in range(GRID_SIZE):
		grid.append([])
		for col in range(GRID_SIZE):
			grid[row].append(0)
			
	setup_visual_grid()
	setup_background()
	spawn_tile()
	spawn_tile()
	update_visuals()
	
func setup_visual_grid():
	var gridContainer = $GridContainer
	gridContainer.columns = GRID_SIZE
	gridContainer.add_theme_constant_override("h_separation", TILE_GAP)
	gridContainer.add_theme_constant_override("v_separation", TILE_GAP)
	
	for i in range(GRID_SIZE * GRID_SIZE):
		var cell = ColorRect.new()
		cell.custom_minimum_size = Vector2(TILE_SIZE, TILE_SIZE)
		cell.color = Color("776e65")
		
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.text = ""
		label.add_theme_font_size_override("font_size", 48)
		cell.add_child(label)
		gridContainer.add_child(cell)
		print("added cell ", i)
		
	var board_size = GRID_SIZE * TILE_SIZE + (GRID_SIZE - 1) * TILE_GAP
	
	$GridContainer.position = (get_viewport_rect().size - Vector2(board_size, board_size)) / 2
func get_tile_color(value: int) -> Color:
	match value:
		2:    return Color("ffffff")  # white
		4:    return Color("fffde0")  # pale yellow
		8:    return Color("ff9900")  # vivid orange
		16:   return Color("ff6600")  # deep orange
		32:   return Color("ff3300")  # red orange
		64:   return Color("ff0000")  # pure red
		128:  return Color("ffdd00")  # vivid yellow
		256:  return Color("ffe500")  # golden yellow
		512:  return Color("00cc44")  # vivid green
		1024: return Color("0099ff")  # vivid blue
		2048: return Color("aa00ff")  # vivid purple
		_:    return Color("000000")  # black
		
func spawn_tile():
	var empty_cells = []
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if grid[row][col] == 0:
				empty_cells.append(Vector2(row, col))
	
	var random_cell = empty_cells[randi() % empty_cells.size()]
	
	grid[random_cell.x][random_cell.y] = 4 if randf() > 0.8 else 2
	
func update_visuals():
	var cells = $GridContainer.get_children()
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var index = row * GRID_SIZE + col
			var cell = cells[index]
			var value = grid[row][col]
			var label = cell.get_child(0)
			
			if value == 0:
				cell.color = Color("#EEF0EB")
				label.text = ""
			else:
				cell.color = get_tile_color(value)
				label.text = str(value)
			
			if value <= 4:
				label.add_theme_color_override("font_color", Color("776e65"))  # dark text for light tiles
			else:
				label.add_theme_color_override("font_color", Color("ffffff"))
				
func setup_background():
	var canvas = $CanvasLayer
	canvas.layer = -1
	
	# Background
	var bg = ColorRect.new()
	bg.color = Color("#284B63")  # classic 2048 cream color
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)  # fills entire screen
	canvas.add_child(bg)
	
	# Title
	var title = Label.new()
	title.text = ""
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color("#F4F9E9"))
	title.position = Vector2(500, 20)
	canvas.add_child(title)
	
func _input(event: InputEvent) -> void:
	# Arrow key controls
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:    move(Vector2.UP)
			KEY_DOWN:  move(Vector2.DOWN)
			KEY_LEFT:  move(Vector2.LEFT)
			KEY_RIGHT: move(Vector2.RIGHT)
	# Record where the finger touched down
	if event is InputEventScreenTouch and event.pressed:
		touch_start = event.position
		# When finger lifts, calculate the swipe
	if event is InputEventScreenTouch and not event.pressed:
		var swipe = event.position - touch_start
		if swipe.length() > 50:  # minimum swipe distance
			if abs(swipe.x) > abs(swipe.y):
				if swipe.x > 0:
					move(Vector2.RIGHT)
				else:
					move(Vector2.LEFT)
			else:
				if swipe.y > 0:
					move(Vector2.DOWN)
				else:
					move(Vector2.UP)

func move(direction: Vector2) -> void:
	var moved = false
	
	if direction == Vector2.LEFT:
		for row in range(GRID_SIZE):
			var result = merge_row(grid[row])
			if result != grid[row]:
				moved = true
			grid[row] = result

	elif direction == Vector2.RIGHT:
		for row in range(GRID_SIZE):
			var reversed = grid[row].duplicate()
			reversed.reverse()
			var result = merge_row(reversed)
			result.reverse()
			if result != grid[row]:
				moved = true
			grid[row] = result

	elif direction == Vector2.UP:
		for col in range(GRID_SIZE):
			var column = []
			for row in range(GRID_SIZE):
				column.append(grid[row][col])
			var result = merge_row(column)
			for row in range(GRID_SIZE):
				if grid[row][col] != result[row]:
					moved = true
				grid[row][col] = result[row]

	elif direction == Vector2.DOWN:
		for col in range(GRID_SIZE):
			var column = []
			for row in range(GRID_SIZE):
				column.append(grid[row][col])
			column.reverse()
			var result = merge_row(column)
			result.reverse()
			for row in range(GRID_SIZE):
				if grid[row][col] != result[row]:
					moved = true
				grid[row][col] = result[row]

	if moved:
		spawn_tile()
		update_visuals()

func merge_row(row: Array) -> Array:
	# Step 1: compress - remove zeros
	var compressed = []
	for val in row:
		if val != 0:
			compressed.append(val)
	
	# Step 2: merge adjacent equal values
	var merged = []
	var i = 0
	while i < compressed.size():
		if i + 1 < compressed.size() and compressed[i] == compressed[i + 1]:
			merged.append(compressed[i] * 2)
			i += 2
		else:
			merged.append(compressed[i])
			i += 1
	
	# Step 3: pad with zeros to fill the row
	while merged.size() < GRID_SIZE:
		merged.append(0)
	
	return merged
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
