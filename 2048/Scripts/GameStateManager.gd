extends Node

@onready var move_manager = $"../MoveManager"
@onready var grid_manager = $"../GridManager"
@onready var score_manager = $"../ScoreManager"
@onready var input_manager = $"../InputManager"

var options_scene = preload("res://2048/Scenes/2048Options.tscn")
var end_scene = preload("res://2048/Scenes/2048EndScreen.tscn")

var game_active := true

func _ready() -> void:
	input_manager.on_move.connect(_on_move)

func _on_move(direction: Vector2) -> void:
	if not game_active:
		return

	var moved = move_manager.move(direction)

	if moved:
		score_manager.update_score(grid_manager.score)

		if grid_manager.check_win():
			game_active = false
			show_win()
		elif grid_manager.is_game_over():
			game_active = false
			show_lose()

# =========================
# WIN / LOSE OVERLAYS
# =========================

func show_win() -> void:
	
	SaveManager.record_2048_score(
		grid_manager.score,
		grid_manager.get_highest_tile()
	)
	var endscreen = end_scene.instantiate()

	get_parent().add_child(endscreen)

	endscreen.setup(
		true,
		grid_manager.score,
		grid_manager.get_highest_tile()
	)

func show_lose() -> void:
	SaveManager.record_2048_score(
		grid_manager.score,
		grid_manager.get_highest_tile()
	)
	var endscreen = end_scene.instantiate()

	get_parent().add_child(endscreen)

	endscreen.setup(
		false,
		grid_manager.score,
		grid_manager.get_highest_tile()
	)

# =========================
# OPTIONS MENU
# =========================

func show_options() -> void:
	var menu = options_scene.instantiate()
	add_child(menu)
