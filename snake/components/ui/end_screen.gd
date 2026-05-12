extends CanvasLayer

@onready var title_label = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var highscore_label = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/HighscoreLabel
@onready var score_label = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/ScoreLabel
@onready var play_again_button = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/PlayAgainButton
@onready var menu_button = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/MainMenuButton


func setup(score: int, high_score: int) -> void:
		title_label.text = "GAME OVER"
		highscore_label.text = "HIGH SCORE: " + str(high_score)
		score_label.text = "SCORE: " + str(score)

func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
