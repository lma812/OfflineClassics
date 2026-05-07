extends Control
#const COLORS = preload("res://shared/theme/colors.tres")

# Called when the node enters the scene tree for the first time.
var snake = SaveManager.get_game("snake")
var high_score = snake["high_score"]
var games_played = snake["games_played"]

func _ready():
	#print(COLORS)
	#print(COLORS.primary)
	#$BacktoMenu.modulate = COLORS.primary
	$Menu/BacktoMenu.pressed.connect(_on_back_button_pressed)
	$Menu/StartGame.pressed.connect(_on_start_game_button_pressed)
	$Hud.get_node("ScoreLabel").text = "HIGHSCORE: %s \t GAMES PLAYED: %s" % [high_score, games_played]
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_start_game_button_pressed():
	get_tree().change_scene_to_file("res://snake/snake_game.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
