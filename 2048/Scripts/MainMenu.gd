extends Control

@onready var play_button = $Menu/StartGame
@onready var quit_button = $Menu/BacktoMenu

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	var data = SaveManager.get_game("2048")

	$Hud.get_node("ScoreLabel").text = \
		"HIGHSCORE: %s \t BEST TILE: %s \t GAMES: %s" % [
			int(data["high_score"]),
			int(data["best_tile"]),
			int(data["games_played"])
		]

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://2048/Scenes/2048.tscn"
	)

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://main_menu.tscn"
	)
