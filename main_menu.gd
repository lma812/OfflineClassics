extends Control
@onready var yahtzee_button = $CenterContainer/VBoxContainer/HBoxContainer/YahtzeeButton
@onready var snake_button = $CenterContainer/VBoxContainer/HBoxContainer2/SnakeButton
@onready var game2048_button = $CenterContainer/VBoxContainer/HBoxContainer3/Game2048Button
@onready var wordle_button = $CenterContainer/VBoxContainer/HBoxContainer4/WordleButton
@onready var word_bomb_button = $CenterContainer/VBoxContainer/HBoxContainer5/WordBombButton

@onready var yahtzee_info = $CenterContainer/VBoxContainer/HBoxContainer/YahtzeeInfoButton
@onready var snake_info = $CenterContainer/VBoxContainer/HBoxContainer2/SnakeInfoButton
@onready var game2048_info = $CenterContainer/VBoxContainer/HBoxContainer3/Game2048InfoButton
@onready var wordle_info = $CenterContainer/VBoxContainer/HBoxContainer4/WordleInfoButton
@onready var word_bomb_info = $CenterContainer/VBoxContainer/HBoxContainer5/WordBombInfoButton

var info_popup_scene = preload("res://shared/info_popup.tscn")

func _ready():
	yahtzee_button.pressed.connect(_on_yahtzee_pressed)
	snake_button.pressed.connect(_on_snake_pressed)
	game2048_button.pressed.connect(_on_2048_pressed)
	wordle_button.pressed.connect(_on_wordle_pressed)
	word_bomb_button.pressed.connect(_on_word_bomb_pressed)

	yahtzee_info.pressed.connect(func(): _on_info_pressed("yahtzee"))
	snake_info.pressed.connect(func(): _on_info_pressed("snake"))
	game2048_info.pressed.connect(func(): _on_info_pressed("2048"))
	wordle_info.pressed.connect(func(): _on_info_pressed("wordle"))
	word_bomb_info.pressed.connect(func(): _on_info_pressed("word_bomb"))

func _on_yahtzee_pressed():
	get_tree().change_scene_to_file("res://yahtzee/yahtzee.tscn")

func _on_snake_pressed():
	get_tree().change_scene_to_file("res://snake/components/ui/start_screen.tscn")

func _on_2048_pressed():
	get_tree().change_scene_to_file("res://2048/Scenes/2048MainMenu.tscn")

func _on_wordle_pressed():
	get_tree().change_scene_to_file("res://wordle/Scenes/MainMenu.tscn")

func _on_word_bomb_pressed():
	get_tree().change_scene_to_file("res://word_bomb/scenes/word_bomb.tscn")

func _on_info_pressed(game: String) -> void:
	var data = SaveManager.get_game(game)
	var text = "Games Played: %s\nHigh Score: %s" % [
		str(data.get("games_played", 0)),
		str(data.get("high_score", 0))
	]
	
	# 2048 has an extra best tile field
	if game == "2048":
		text += "\nBest Tile: %s" % str(data.get("best_tile", 0))

	var popup = info_popup_scene.instantiate()
	add_child(popup)
	popup.setup(game.capitalize().replace("_", " "), text)
