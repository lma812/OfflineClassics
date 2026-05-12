extends Node

@onready var KeyboardManager = $KeyboardManager
@onready var input_label = $CenterContainer/VBoxContainer/Guess
@onready var score_label = $Panel/TopBar/ScoreLabel
@onready var constraint_label = $Panel/Constraint
@onready var timer = $Panel/Timer
@onready var game_over_ui = $GameOverScreen

var options_scene = preload("res://shared/options_menu.tscn")

var word_set := {}
var current_input := ""
var current_constraint := ""
var used_words := {}
var lives = 3 
var score = 0
var seconds = 15
var timer_id = 0
var is_paused: = false

func _ready() -> void:
	lives = 3
	score = 0 
	seconds = 15
	load_words()
	KeyboardManager.create_keyboard()
	KeyboardManager.letter_pressed.connect(_on_letter)
	KeyboardManager.backspace_pressed.connect(_on_backspace)
	KeyboardManager.enter_pressed.connect(_on_enter)
	current_constraint = generate_constraint()
	constraint_label.text = current_constraint
	count_down(seconds)
	
func load_words():
	var file = FileAccess.open("res://word_bomb/assets/dict.txt", FileAccess.READ)
	for line in file.get_as_text().split("\n"):
		word_set[line.strip_edges()] = true
	
func update_ui():
	input_label.text = current_input
	print(input_label.text)
	
func _on_backspace() -> void:
	if current_input.length() > 0:
		current_input = current_input.substr(0, current_input.length() - 1)
		update_ui()

func _on_letter(key:String) -> void:
	if current_input.length() < 34:
		current_input += key.to_upper()
		update_ui()

func _on_enter() -> void:
	var word = current_input.to_lower()

	if validate(word):
		handle_correct(word)
	else:
		handle_wrong(word)

	current_input = ""
	update_ui()
	
func validate(word:String) -> bool:
	# must have the str literal in the word
	# must be a valid word. 
	word = word.to_upper()

	if not word_set.has(word):
		return false

	if not word.contains(current_constraint):
		return false

	if used_words.has(word):
		return false

	return true

func handle_correct(word: String):
	used_words[word] = true

	score += word.length()  # or your scoring system
	score_label.text = "SCORE: %s" % str(score)
	
	current_constraint = generate_constraint()
	constraint_label.text = current_constraint
	count_down(seconds)
	
func handle_wrong(word: String):
	lives -= 1
	shake_ui()

func generate_constraint() -> String:
	var words = word_set.keys()
	var random_number = randi_range(1,3)
	var random_word = words[randi() % words.size()]
	
	return random_word.substr(0, random_number) 

var shake_strength := 8.0
var shake_time := 0.2
var original_pos := Vector2.ZERO

func shake_ui():
	if not original_pos:
		original_pos = $CenterContainer.position

	_start_shake()

func _start_shake():
	var elapsed := 0.0

	while elapsed < shake_time:
		var offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		$CenterContainer.position = original_pos + offset

		await get_tree().process_frame
		elapsed += get_process_delta_time()

	$CenterContainer.position = original_pos
	
func count_down(seconds: int) -> void:
	timer_id += 1
	var current_id = timer_id

	for i in range(seconds, -1, -1):
		# cancel old countdowns
		if current_id != timer_id:
			return

		timer.text = str(i)
		print(i)
		var elapsed := 0.0
		while elapsed < 1.0:
			if current_id != timer_id:
				return
			if not is_inside_tree():
				return
			while is_paused:
				if not is_inside_tree():
					return
				await get_tree().process_frame
			await get_tree().process_frame
			elapsed += get_process_delta_time()
	
	handle_game_over()

func handle_game_over() -> void: 
	var reason = current_constraint
	
	SaveManager.set_high_score("word_bomb", score)
	SaveManager.increment_games_played("word_bomb")
	
	var word_bomb = SaveManager.get_game("word_bomb")
	show_game_over_screen(reason, str(word_bomb["high_score"]))
	
func show_game_over_screen(reason: String, new_high_score: String):
	game_over_ui.show()
	# Update the label to say why they died
	print("highscore:", new_high_score)
	game_over_ui.get_node("VBoxContainer/Highscore").text = "HIGHSCORE: %s" % new_high_score
	game_over_ui.get_node("VBoxContainer/GameOver").text = "GAME OVER"
	game_over_ui.get_node("VBoxContainer/Reason").text = "work on this!!: " + reason

func _on_restart_button_pressed():
	# Reloads the current scene to start fresh
	print("scene reload")
	get_tree().reload_current_scene()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_options_button_pressed() -> void:
	is_paused = true
	var options_menu = options_scene.instantiate()
	options_menu.resume_requested.connect(_on_resume)
	add_child(options_menu)

func _on_resume() -> void:
	is_paused = false
