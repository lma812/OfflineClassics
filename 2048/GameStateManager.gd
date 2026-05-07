extends Node

@onready var move_manager = $"../MoveManager"
@onready var grid_manager = $"../GridManager"
@onready var score_manager = $"../ScoreManager"
@onready var input_manager = $"../InputManager"

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
	_create_overlay(true)

func show_lose() -> void:
	_create_overlay(false)

func _create_overlay(won: bool) -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 10
	get_parent().add_child(canvas)

	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	_build_overlay(root, won)

# =========================
# OPTIONS MENU
# =========================

func show_options() -> void:
	if get_parent().get_node_or_null("OptionsCanvas"):
		return

	var canvas = CanvasLayer.new()
	canvas.name = "OptionsCanvas"
	canvas.layer = 10
	get_parent().add_child(canvas)

	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(520, 420)
	center.add_child(panel)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "Options"
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(_make_button("Resume", func(): canvas.queue_free()))
	vbox.add_child(_make_button("Restart", func(): get_tree().reload_current_scene()))
	vbox.add_child(_make_button("Main Menu", func(): get_tree().change_scene_to_file("res://main_menu.tscn")))

# =========================
# OVERLAY BUILDER
# =========================

func _build_overlay(root: Control, won: bool) -> void:
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(520, 500)
	center.add_child(panel)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	var icon = Label.new()
	icon.text = "🎉" if won else "😢"
	icon.add_theme_font_size_override("font_size", 80)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon)

	var elapsed = score_manager.elapsed_time
	var minutes = int(elapsed) / 60
	var seconds = int(elapsed) % 60
	var time_str = "%d:%02d" % [minutes, seconds]

	var message := ""
	if won:
		message = "Congratulations!\nYou reached 2048!\n\nScore: %d\nTime: %s" % [grid_manager.score, time_str]
	else:
		message = "Game Over!\n\nHighest Tile: %d\nScore: %d\nTime: %s" % [
			grid_manager.get_highest_tile(),
			grid_manager.score,
			time_str
		]

	var label = Label.new()
	label.text = message
	label.add_theme_font_size_override("font_size", 36)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(label)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 180)
	vbox.add_child(row)

	row.add_child(_make_button("Play Again", func(): get_tree().reload_current_scene()))
	row.add_child(_make_button("Main Menu", func(): get_tree().change_scene_to_file("res://main_menu.tscn")))

# =========================
# HELPER
# =========================

func _make_button(text: String, action: Callable) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 28)
	btn.pressed.connect(action)
	return btn
