extends Control

func _ready():
	$CenterContainer/VBoxContainer/YahtzeeButton.pressed.connect(_on_yahtzee_pressed)
	$CenterContainer/VBoxContainer/SnakeButton.pressed.connect(_on_snake_pressed)
	#$CenterContainer/VBoxContainer/Game2048Button.pressed.connect(_on_2048_pressed)

func _on_yahtzee_pressed():
	get_tree().change_scene_to_file("res://yahtzee/yahtzee.tscn")

func _on_snake_pressed():
	get_tree().change_scene_to_file("res://snake/components/ui/start_screen.tscn")
#
#func _on_2048_pressed():
	#get_tree().change_scene_to_file("res://game_2048/game_2048.tscn")
