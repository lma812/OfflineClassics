extends Node2D

const GRID_SIZE = 4
const TILE_SIZE = 120
const TILE_GAP = 10

var grid = []
var touch_start = Vector2.ZERO
var elapsed_time = 0.0
var score = 0
var timer_label: Label
var score_label: Label

const BOARD_X = 100
const BOARD_Y = 300

func _ready() -> void:
	print("2048 loaded")
	setup_background()
	grid = []
	for row in range(GRID_SIZE):
		grid.append([])
		for col in range(GRID_SIZE):
			grid[row].append(0)
	setup_visual_grid()
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
		cell.color = Color("#EEF0EB")
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.text = ""
		label.add_theme_font_size_override("font_size", 48)
		cell.add_child(label)
		gridContainer.add_child(cell)
	$GridContainer.position = Vector2(BOARD_X, BOARD_Y)

func setup_background():
	var canvas = $CanvasLayer
	canvas.layer = -1
	var bg = ColorRect.new()
	bg.color = Color("#284B63")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(bg)
	var board_size = GRID_SIZE * TILE_SIZE + (GRID_SIZE - 1) * TILE_GAP
	var padding = 20
	var border = 6
	var border_rect = ColorRect.new()
	border_rect.color = Color("#F4F9E9")
	border_rect.position = Vector2(BOARD_X - padding - border, BOARD_Y - 80 - padding - border)
	border_rect.size = Vector2(
		board_size + (padding + border) * 2,
		board_size + 80 + 60 + (padding + border) * 2
	)
	canvas.add_child(border_rect)
	
	var inner_bg = ColorRect.new()
	inner_bg.color = Color("#284B63")
	inner_bg.position = Vector2(BOARD_X - padding, BOARD_Y - 80 - padding)
	inner_bg.size = Vector2(board_size + padding * 2, board_size + 80 + 60 + padding * 2)
	canvas.add_child(inner_bg)
	
	var title = Label.new()
	title.text = "2048"
	title.add_theme_font_size_override("font_size", 60)
	title.add_theme_color_override("font_color", Color("#F4F9E9"))
	title.position = Vector2(BOARD_X + 185, BOARD_Y - 90)
	canvas.add_child(title)
	
	score_label = Label.new()
	score_label.text = "SCORE: 0"
	score_label.add_theme_font_size_override("font_size", 28)
	score_label.add_theme_color_override("font_color", Color("#F4F9E9"))
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	score_label.position = Vector2(BOARD_X, BOARD_Y + board_size + 15)
	score_label.size = Vector2(255, 40)
	canvas.add_child(score_label)
	
	timer_label = Label.new()
	timer_label.text = "TIME: 0:00"
	timer_label.add_theme_font_size_override("font_size", 28)
	timer_label.add_theme_color_override("font_color", Color("#F4F9E9"))
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timer_label.position = Vector2(BOARD_X + 255, BOARD_Y + board_size + 15)
	timer_label.size = Vector2(255, 40)
	canvas.add_child(timer_label)
	
	var options_btn = Button.new()
	options_btn.text = "⚙"
	options_btn.add_theme_font_size_override("font_size", 36)
	options_btn.position = Vector2(BOARD_X + 430, BOARD_Y - 90)
	options_btn.size = Vector2(80, 80)
	options_btn.pressed.connect(show_options_menu)
	canvas.add_child(options_btn)

func show_options_menu() -> void:
	if get_node_or_null("OptionsCanvas"):
		return
	var options_canvas = CanvasLayer.new()
	options_canvas.name = "OptionsCanvas"
	options_canvas.layer = 10
	add_child(options_canvas)
	
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	options_canvas.add_child(dim)
	
	var border = ColorRect.new()
	border.color = Color("#F4F9E9")
	border.position = Vector2(160, 400)
	border.size = Vector2(406, 420)
	options_canvas.add_child(border)
	
	var panel = ColorRect.new()
	panel.color = Color("#284B63")
	panel.position = Vector2(166, 406)
	panel.size = Vector2(394, 408)
	options_canvas.add_child(panel)
	
	var title = Label.new()
	title.text = "Options"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("#F4F9E9"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(166, 420)
	title.size = Vector2(394, 70)
	options_canvas.add_child(title)
	
	var resume_btn = Button.new()
	resume_btn.text = "Resume"
	resume_btn.add_theme_font_size_override("font_size", 32)
	resume_btn.position = Vector2(210, 520)
	resume_btn.size = Vector2(300, 70)
	resume_btn.pressed.connect(func():
		options_canvas.queue_free()
	)
	options_canvas.add_child(resume_btn)
	
	var restart_btn = Button.new()
	restart_btn.text = "Restart"
	restart_btn.add_theme_font_size_override("font_size", 32)
	restart_btn.position = Vector2(210, 610)
	restart_btn.size = Vector2(300, 70)
	restart_btn.pressed.connect(restart)
	options_canvas.add_child(restart_btn)
	
	var menu_btn = Button.new()
	menu_btn.text = "Main Menu"
	menu_btn.add_theme_font_size_override("font_size", 32)
	menu_btn.position = Vector2(210, 700)
	menu_btn.size = Vector2(300, 70)
	menu_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://main_menu.tscn")
	)
	options_canvas.add_child(menu_btn)

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
	return Color("000000")

func spawn_tile():
	var empty_cells = []
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if grid[row][col] == 0:
				empty_cells.append(Vector2(row, col))
	if empty_cells.is_empty():
		return
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

func show_overlay(won: bool) -> void:
	var overlay_canvas = CanvasLayer.new()
	overlay_canvas.layer = 10
	add_child(overlay_canvas)
	
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay_canvas.add_child(dim)
	
	var border = ColorRect.new()
	border.color = Color("#F4F9E9")
	border.position = Vector2(90, 300)
	border.size = Vector2(532, 500)
	overlay_canvas.add_child(border)
	
	var panel = ColorRect.new()
	panel.color = Color("#284B63")
	panel.position = Vector2(96, 306)
	panel.size = Vector2(520, 488)
	overlay_canvas.add_child(panel)
	
	var icon = Label.new()
	icon.text = "🎉" if won else "😢"
	icon.add_theme_font_size_override("font_size", 80)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.position = Vector2(100, 316)
	icon.size = Vector2(520, 100)
	overlay_canvas.add_child(icon)
	
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	var time_str = "%d:%02d" % [minutes, seconds]
	var message = ""
	if won:
		message = "Congratulations!\nYou reached 2048!\n\nScore: %d\nTime: %s" % [score, time_str]
	else:
		message = "Game Over!\n\nHighest Tile: %d\nScore: %d\nTime: %s" % [get_highest_tile(), score, time_str]
		
	var label = Label.new()
	label.text = message
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_color", Color("#F4F9E9"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(100, 420)
	label.size = Vector2(520, 260)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	overlay_canvas.add_child(label)
	
	var play_btn = Button.new()
	play_btn.text = "Play Again"
	play_btn.add_theme_font_size_override("font_size", 28)
	play_btn.position = Vector2(104, 720)
	play_btn.size = Vector2(248, 60)
	play_btn.pressed.connect(restart)
	overlay_canvas.add_child(play_btn)
	
	var menu_btn = Button.new()
	menu_btn.text = "Main Menu"
	menu_btn.add_theme_font_size_override("font_size", 28)
	menu_btn.position = Vector2(360, 720)
	menu_btn.size = Vector2(248, 60)
	menu_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://main_menu.tscn")
	)
	overlay_canvas.add_child(menu_btn)

func get_highest_tile() -> int:
	var highest = 0
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if grid[row][col] > highest:
				highest = grid[row][col]
	return highest

func restart() -> void:
	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:    move(Vector2.UP)
			KEY_DOWN:  move(Vector2.DOWN)
			KEY_LEFT:  move(Vector2.LEFT)
			KEY_RIGHT: move(Vector2.RIGHT)
			KEY_W:     show_overlay(true)
			KEY_L:     show_overlay(false)
	if event is InputEventScreenTouch and event.pressed:
		touch_start = event.position
	if event is InputEventScreenTouch and not event.pressed:
		var swipe = event.position - touch_start
		if swipe.length() > 50:
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
		if check_win():
			show_overlay(true)
		elif is_game_over():
			show_overlay(false)

func merge_row(row: Array) -> Array:
	var compressed = []
	for val in row:
		if val != 0:
			compressed.append(val)
	var merged = []
	var i = 0
	while i < compressed.size():
		if i + 1 < compressed.size() and compressed[i] == compressed[i + 1]:
			var new_val = compressed[i] * 2
			score += new_val
			score_label.text = "SCORE: " + str(score)
			merged.append(new_val)
			i += 2
		else:
			merged.append(compressed[i])
			i += 1
	while merged.size() < GRID_SIZE:
		merged.append(0)
	return merged

func _process(delta: float) -> void:
	if timer_label == null:
		return
	elapsed_time += delta
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	timer_label.text = "TIME: %d:%02d" % [minutes, seconds]
