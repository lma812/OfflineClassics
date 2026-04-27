extends Control

func _ready():
	$CenterContainer/VBoxContainer/YahtzeeButton.pressed.connect(_on_yahtzee_pressed)
	#$CenterContainer/VBoxContainer/SnakeButton.pressed.connect(_on_snake_pressed)
	get_node("CenterContainer/VBoxContainer/2048Button").pressed.connect(_on_2048_pressed)

func _on_yahtzee_pressed():
	get_tree().change_scene_to_file("res://yahtzee/yahtzee.tscn")

func _on_snake_pressed():
	get_tree().change_scene_to_file("res://snake/snake.tscn")
#
func _on_2048_pressed():
	print("switching to 2048")
	get_tree().change_scene_to_file("res://2048/2048.tscn")
