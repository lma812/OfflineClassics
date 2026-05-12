extends CanvasLayer

@onready var resume_button = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/ResumeButton
@onready var restart_button = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/RestartButton
@onready var menu_button = $Overlay/CenterContainer/Panel/MarginContainer/VBoxContainer/MainMenuButton

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_resume_pressed() -> void:
	get_tree().current_scene.get_node(
		
		"GameManager"
	).menu_open = false

	queue_free()

func _on_restart_pressed() -> void:
	var game_manager = get_tree().current_scene.get_node(
		"GameManager"
	)

	game_manager.menu_open = false

	game_manager.new_game()

	queue_free()

func _on_menu_pressed() -> void:
	get_tree().current_scene.get_node(
		"GameManager"
	).menu_open = false

	get_tree().change_scene_to_file(
		"res://main_menu.tscn"
	)
