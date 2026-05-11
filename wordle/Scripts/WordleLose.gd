extends Control

@onready var restart_button = $CenterContainer/Panel/MarginContainer/VBoxContainer/RestartButton
@onready var menu_button = $CenterContainer/Panel/MarginContainer/VBoxContainer/MainMenuButton
@onready var answer_label = $CenterContainer/Panel/MarginContainer/VBoxContainer/AnswerLabel

func setup(correct_word: String) -> void:
	answer_label.text = "The word was: " + correct_word

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_restart_pressed() -> void:
	var game_manager = get_tree().current_scene.get_node("GameManager")
	game_manager.menu_open = false
	game_manager.new_game()
	queue_free()

func _on_menu_pressed() -> void:
	get_tree().current_scene.get_node("GameManager").menu_open = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
