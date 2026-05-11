extends Node

const ROWS = 6
const COLS = 5
var keyboard_buttons = {}
var score := 0
var streak := 0
var high_score := 0

@onready var guess_grid = $"../CenterContainer/VBoxContainer/GuessGrid"
@onready var input_manager = $"../InputManager"
@onready var word_manager = $"../WordManager"
@onready var options_button = $"../CenterContainer/VBoxContainer/TopBar/OptionsButton"
@onready var score_label = $"../CenterContainer/VBoxContainer/TopBar/ScoreLabel"

var tile_scene = preload("res://wordle/scenes/LetterTile.tscn")

var tiles = []

var current_row := 0
var current_col := 0

var guesses = []

func _ready() -> void:
	create_grid()
	create_keyboard()
	load_save_data()

	input_manager.letter_pressed.connect(_on_letter)
	input_manager.backspace_pressed.connect(_on_backspace)
	input_manager.enter_pressed.connect(_on_enter)
	options_button.pressed.connect(show_options)

func create_grid() -> void:
	for row in range(ROWS):
		tiles.append([])
		guesses.append([])

		for col in range(COLS):
			var tile = tile_scene.instantiate()
			guess_grid.add_child(tile)

			tiles[row].append(tile)
			guesses[row].append("")

func create_keyboard() -> void:
	var keyboard = get_parent().get_node("CenterContainer/VBoxContainer/KeyboardContainer")

	var rows = [
	["Q","W","E","R","T","Y","U","I","O","P"],
	["A","S","D","F","G","H","J","K","L","⌫"],
	["Z","X","C","V","B","N","M","ENTER"]
]

	for row_index in range(rows.size()):
		var row_container = keyboard.get_node("Row" + str(row_index + 1))

		for key in rows[row_index]:
			var button = Button.new()

			button.text = key
			button.custom_minimum_size = Vector2(42, 58)

			button.add_theme_font_size_override("font_size", 24)

			if key == "ENTER":
				button.custom_minimum_size.x = 90

			if key == "⌫":
				button.custom_minimum_size.x = 55

			button.pressed.connect(func():
				_on_keyboard_pressed(key)
			)

			row_container.add_child(button)
			keyboard_buttons[key] = button

func _on_keyboard_pressed(key: String) -> void:
	if key == "ENTER":
		_on_enter()
	elif key == "⌫":
		_on_backspace()
	else:
		_on_letter(key)

func _on_letter(letter: String) -> void:
	if current_col >= COLS:
		return

	guesses[current_row][current_col] = letter
	tiles[current_row][current_col].set_letter(letter)

	current_col += 1

func _on_backspace() -> void:
	if current_col <= 0:
		return

	current_col -= 1

	guesses[current_row][current_col] = ""
	tiles[current_row][current_col].clear()

func _on_enter() -> void:
	if current_col < COLS:
		return

	var guess = ""

	for letter in guesses[current_row]:
		guess += letter

	if not word_manager.is_valid_word(guess):
		shake_row(current_row)
		return

	check_guess(guess)

	if guess == word_manager.current_word:
		var gained = add_score(current_row + 1)
		
		show_win_popup(gained)
		save_high_score()
		
		await get_tree().create_timer(1.8).timeout
		reset_game()
		
		return

	current_row += 1
	current_col = 0

	if current_row >= ROWS:
		streak = 0
		save_high_score()
		print("GAME OVER")

func check_guess(guess: String) -> void:
	for i in range(COLS):
		var letter = guess[i]
		var target = word_manager.current_word[i]

		if letter == target:
			tiles[current_row][i].set_state("correct")
			update_keyboard_key(letter, "correct")

		elif word_manager.current_word.contains(letter):
			tiles[current_row][i].set_state("present")
			update_keyboard_key(letter, "present")

		else:
			tiles[current_row][i].set_state("absent")
			update_keyboard_key(letter, "absent")

func reset_game() -> void:
	current_row = 0
	current_col = 0

	# Clear guesses
	guesses.clear()

	for row in range(ROWS):
		guesses.append([])

		for col in range(COLS):
			guesses[row].append("")

			var tile = tiles[row][col]

			tile.clear()

			var style = StyleBoxFlat.new()
			style.bg_color = Color("121213")
			style.border_color = Color("3a3a3c")
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2	
			style.corner_radius_top_left = 4
			style.corner_radius_top_right = 4
			style.corner_radius_bottom_left = 4
			style.corner_radius_bottom_right = 4

			tile.add_theme_stylebox_override("panel", style)

	# Reset keyboard colors
	for key in keyboard_buttons.keys():
		var button = keyboard_buttons[key]

		button.remove_theme_stylebox_override("normal")
		button.remove_meta("state")

	# Choose new word
	word_manager.choose_word()

func shake_row(row_index: int) -> void:
	var row_tiles = tiles[row_index]

	var original_positions = []

	for tile in row_tiles:
		original_positions.append(tile.position)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	for offset in [-14, 14, -10, 10, -6, 6, 0]:
		for tile in row_tiles:
			tween.parallel().tween_property(
				tile,
				"position:x",
				original_positions[row_tiles.find(tile)].x + offset,
				0.045
			)

func show_win_popup(points: int) -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 20
	get_parent().add_child(canvas)

	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var label = Label.new()

	label.text = "Correct! +" + str(points)

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	label.add_theme_font_size_override("font_size", 44)
	label.add_theme_color_override("font_color", Color("6aaa64"))

	center.add_child(label)

	label.modulate.a = 1.0
	label.scale = Vector2(0.9, 0.9)

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	# Small subtle pop
	tween.parallel().tween_property(
		label,
		"scale",
		Vector2.ONE,
		0.2
	)

	# Very gentle upward drift
	tween.parallel().tween_property(
		label,
		"position:y",
		label.position.y - 18,
		1.5
	)

	# Slow fade out
	tween.parallel().tween_property(
		label,
		"modulate:a",
		0.0,
		1.5
	)

func update_keyboard_key(letter: String, state: String) -> void:
	if not keyboard_buttons.has(letter):
		return

	var button = keyboard_buttons[letter]

	# Prevent weaker colors overriding stronger ones
	var current = button.get_meta("state", "")

	if current == "correct":
		return

	if current == "present" and state == "absent":
		return

	button.set_meta("state", state)

	var style = StyleBoxFlat.new()

	match state:
		"correct":
			style.bg_color = Color("6aaa64")

		"present":
			style.bg_color = Color("c9b458")

		"absent":
			style.bg_color = Color("3a3a3c")

	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6

	button.add_theme_stylebox_override("normal", style)

func show_options() -> void:
	if get_parent().get_node_or_null("OptionsLayer"):
		return

	var canvas = CanvasLayer.new()
	canvas.name = "OptionsLayer"
	canvas.layer = 10
	get_parent().add_child(canvas)

	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 300)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "OPTIONS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)

	var resume = Button.new()
	resume.text = "Resume"
	resume.custom_minimum_size = Vector2(220, 60)
	resume.pressed.connect(func():
		canvas.queue_free()
	)
	vbox.add_child(resume)

	var menu = Button.new()
	menu.text = "Main Menu"
	menu.custom_minimum_size = Vector2(220, 60)
	menu.pressed.connect(func():
		get_tree().change_scene_to_file("res://wordle/Scenes/MainMenu.tscn")
	)
	vbox.add_child(menu)
	
func add_score(guess_count: int) -> int:
	var base_score = 100

	# Earlier guesses give more points
	var early_bonus = (6 - guess_count) * 50

	# Streak multiplier
	var streak_bonus = streak * 25

	var gained = base_score + early_bonus + streak_bonus

	score += gained
	streak += 1

	update_score_ui()
	return gained

func update_score_ui() -> void:
	score_label.text = "SCORE: " + str(score)

func save_high_score() -> void:
	var data = {
		"high_score": max(score, high_score)
	}

	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_save_data() -> void:
	if not FileAccess.file_exists("user://save.dat"):
		return

	var file = FileAccess.open("user://save.dat", FileAccess.READ)
	var data = file.get_var()
	file.close()

	high_score = data.get("high_score", 0)
