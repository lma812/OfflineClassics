extends Control

@onready var play_button = $CenterContainer/Panel/MarginContainer/VBoxContainer/PlayButton
@onready var quit_button = $CenterContainer/Panel/MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://2048/Scenes/2048.tscn"
	)

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://main_menu.tscn"
		)
