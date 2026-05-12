extends Node

const ROWS = 6
const COLS = 5

var keyboard_buttons = {}

var score := 0
var high_score := 0

var menu_open := false

@onready var guess_grid = $"../Panel/MarginContainer/VBoxContainer/GuessGrid"
@onready var input_manager = $"../InputManager"
@onready var word_manager = $"../WordManager"
@onready var options_button = $"../Panel/MarginContainer/VBoxContainer/TopBar/OptionsButton"
@onready var score_label = $"../Panel/MarginContainer/VBoxContainer/TopBar/ScoreLabel"

var tile_scene = preload("res://wordle/Scenes/LetterTile.tscn")
var options_scene = preload("res://wordle/Scenes/WordleOptions.tscn")
var lose_scene = preload("res://wordle/Scenes/WordleLose.tscn")

var tiles = []

var current_row := 0
var current_col := 0

var guesses = []

func _ready() -> void:
	create_grid()
	create_keyboard()

	var save = SaveManager.get_game("wordle")

	high_score = save.get("high_score", 0)
	score = 0

	update_score_ui()

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
	var keyboard = $"../Panel/MarginContainer/VBoxContainer/KeyboardContainer"

	var rows = [
		["Q","W","E","R","T","Y","U","I","O","P"],
		["A","S","D","F","G","H","J","K","L","⌫"],
		["Z","X","C","V","B","N","M","ENTER"]
	]

	for row_index in range(rows.size()):
		var row_container = keyboard.get_node(
			"Row" + str(row_index + 1)
		)

		for key in rows[row_index]:
			var button = Button.new()

			button.text = key
			button.custom_minimum_size = Vector2(56, 70)

			button.add_theme_font_size_override(
				"font_size",
				24
			)

			if key == "ENTER":
				button.custom_minimum_size.x = 110

			if key == "⌫":
				button.custom_minimum_size.x = 70

			button.pressed.connect(func():
				_on_keyboard_pressed(key)
			)

			row_container.add_child(button)

			keyboard_buttons[key] = button

# FIX: emit signals instead of calling functions directly
# matches Word Bomb's approach which works reliably on Android
func _on_keyboard_pressed(key: String) -> void:
	if key == "ENTER":
		input_manager.enter_pressed.emit()
	elif key == "⌫":
		input_manager.backspace_pressed.emit()
	else:
		input_manager.letter_pressed.emit(key)

func _on_letter(letter: String) -> void:
	if menu_open:
		return

	if current_col >= COLS:
		return

	guesses[current_row][current_col] = letter

	tiles[current_row][current_col].set_letter(letter)

	current_col += 1

func _on_backspace() -> void:
	if menu_open:
		return

	if current_col <= 0:
		return

	current_col -= 1

	guesses[current_row][current_col] = ""

	tiles[current_row][current_col].clear()

func _on_enter() -> void:
	if menu_open:
		return

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

		SaveManager.set_high_score(
			"wordle",
			score
		)

		SaveManager.increment_games_played(
			"wordle"
		)

		await get_tree().create_timer(1.8).timeout

		reset_round()

		return

	current_row += 1
	current_col = 0

	if current_row >= ROWS:
		SaveManager.increment_games_played("wordle")
		await get_tree().create_timer(0.5).timeout
		show_lose_overlay()
		return

func check_guess(guess: String) -> void:
	var target_letters = []

	for c in word_manager.current_word:
		target_letters.append(c)

	var states = []

	for i in range(COLS):
		states.append("absent")

	# PASS 1 — correct letters

	for i in range(COLS):
		if guess[i] == word_manager.current_word[i]:
			states[i] = "correct"

			target_letters[i] = null

	# PASS 2 — present letters

	for i in range(COLS):
		if states[i] == "correct":
			continue

		var letter = guess[i]

		if target_letters.has(letter):
			states[i] = "present"

			var index = target_letters.find(letter)

			target_letters[index] = null

	# APPLY STATES

	for i in range(COLS):
		var state = states[i]

		tiles[current_row][i].set_state(state)

		update_keyboard_key(
			guess[i],
			state
		)

func reset_round() -> void:
	current_row = 0
	current_col = 0

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

			tile.add_theme_stylebox_override(
				"panel",
				style
			)

	for key in keyboard_buttons.keys():
		var button = keyboard_buttons[key]

		button.remove_theme_stylebox_override("normal")
		button.remove_meta("state")

	word_manager.choose_word()

func new_game() -> void:
	score = 0

	update_score_ui()

	reset_round()

# FIX: shake the GuessGrid node itself since GridContainer
# overrides child positions, making per-tile tweening impossible
func shake_row(row_index: int) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	var original_x = guess_grid.position.x

	for offset in [-14, 14, -10, 10, -6, 6, 0]:
		tween.tween_property(
			guess_grid,
			"position:x",
			original_x + offset,
			0.045
		)

	tween.tween_property(guess_grid, "position:x", original_x, 0.01)

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

	label.add_theme_font_size_override(
		"font_size",
		44
	)

	label.add_theme_color_override(
		"font_color",
		Color("6aaa64")
	)

	center.add_child(label)

	label.modulate.a = 1.0
	label.scale = Vector2(0.9, 0.9)

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		label,
		"scale",
		Vector2.ONE,
		0.2
	)

	tween.parallel().tween_property(
		label,
		"position:y",
		label.position.y - 18,
		1.5
	)

	tween.parallel().tween_property(
		label,
		"modulate:a",
		0.0,
		1.5
	)

	tween.tween_callback(canvas.queue_free)

func update_keyboard_key(letter: String, state: String) -> void:
	if not keyboard_buttons.has(letter):
		return

	var button = keyboard_buttons[letter]

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

	button.add_theme_stylebox_override(
		"normal",
		style
	)

func show_lose_overlay() -> void:
	menu_open = true
	var overlay = lose_scene.instantiate()
	get_parent().add_child(overlay)
	overlay.setup(word_manager.current_word)

func show_options() -> void:
	if get_parent().get_node_or_null("OptionsMenu"):
		return

	menu_open = true

	var menu = options_scene.instantiate()

	get_parent().add_child(menu)

func add_score(guess_count: int) -> int:
	var base_score = 100
	var early_bonus = (6 - guess_count) * 50
	var gained = base_score + early_bonus

	score += gained

	high_score = max(high_score, score)

	update_score_ui()

	return gained

func update_score_ui() -> void:
	score_label.text = \
		"SCORE: %s   BEST: %s" % [
			score,
			high_score
		]
