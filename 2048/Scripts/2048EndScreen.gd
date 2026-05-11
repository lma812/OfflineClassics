extends CanvasLayer

@onready var title_label = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var subtitle_label = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/SubtitleLabel
@onready var score_label = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/ScoreLabel
@onready var play_again_button = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/PlayAgainButton
@onready var menu_button = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/MainMenuButton

func setup(won: bool, score: int, highest_tile: int) -> void:
	if won:
		title_label.text = "YOU WIN!"
		subtitle_label.text = "Can you reach 4096?"
	else:
		title_label.text = "GAME OVER"
		subtitle_label.text = "Highest Tile: " + str(highest_tile)

	score_label.text = "SCORE: " + str(score)

func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
