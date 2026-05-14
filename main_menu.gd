extends Control

# ─── Constants ───────────────────────────────────────────────────────────────
const SIDE_SCALE: float = 0.80
const CENTER_SCALE: float = 1.0
const ANIM_DURATION: float = 0.28

# ─── State ───────────────────────────────────────────────────────────────────
var current_index: int = 0
var swipe_start: Vector2 = Vector2.ZERO
var dragging: bool = false
var is_animating: bool = false
var dots: Array = []

# ─── Game Definitions ────────────────────────────────────────────────────────
var GAMES: Array = [
	{
		"name":   "2048",
		"image":  preload("res://2048/Assets/2048CoverImage.png"),
		"scene":  "res://2048/Scenes/2048MainMenu.tscn",
		"accent": Color("f59e0b"),
		"glow": Color(0.15686275, 0.29411766, 0.3882353, 0.15),
		"desc":   "Slide & merge tiles to reach 2048",
		"save_key": "2048",
		"stats": ["high_score", "games_played", "best_tile"],
	},
	{
		"name":   "Snake",
		"image":  preload("res://snake/assets/snakeTitleImage-removebg-preview.png"),
		"scene":  "res://snake/components/ui/start_screen.tscn",
		"accent": Color("22c55e"),
		"glow": Color(0.15686275, 0.29411766, 0.3882353, 0.15),
		"desc":   "Eat, grow, don't bite  yourself",
		"save_key": "snake",
		"stats": ["high_score", "games_played"]
	},
	{
		"name":   "Wordle",
		"image":  preload("res://wordle/Assets/Wordle.png"),
		"scene":  "res://wordle/Scenes/MainMenu.tscn",
		"accent": Color("84cc16"),
		"glow": Color(0.15686275, 0.29411766, 0.3882353, 0.15),
		"desc":   "Guess the hidden word in 6 tries",
		"save_key": "wordle",
		"stats": ["high_score", "games_played"],
	},
	{
		"name":   "Yahtzee",
		"image":  preload("res://yahtzee/assets/yahtzeeCoverImage.png"),
		"scene":  "res://yahtzee/yahtzee.tscn",
		"accent": Color("ef4444"),
		"glow": Color(0.15686275, 0.29411766, 0.3882353, 0.15),
		"desc":   "Roll dice, score combos, outsmart all",
		"save_key": "yahtzee",
		"stats": ["high_score", "games_played"],
	},
	{
		"name":   "Word Bomb",
		"image":  preload("res://word_bomb/assets/bomb-removebg-preview.png"),
		"scene":  "res://word_bomb/scenes/start_screen.tscn",
		"accent": Color("ec4899"),
		"glow": Color(0.15686275, 0.29411766, 0.3882353, 0.15),
		"desc":   "Beat the clock — spell words fast",
		"save_key": "word_bomb",
		"stats": ["high_score", "games_played"],
	}
]

# ─── Node References ──────────────────────────────────────────────────────────
@onready var bg_glow: ColorRect = $BgGlow
@onready var left_card: Panel = $MarginContainer/Layout/CarouselContainer/LeftCard
@onready var center_card: Panel = $MarginContainer/Layout/CarouselContainer/CenterCard
@onready var right_card: Panel = $MarginContainer/Layout/CarouselContainer/RightCard
@onready var dots_row: HBoxContainer = $MarginContainer/Layout/DotsBar/DotsRow
@onready var prev_btn: Button = $MarginContainer/Layout/DotsBar/PrevBtn
@onready var next_btn: Button = $MarginContainer/Layout/DotsBar/NextBtn

var base_left_x: float = 0.0
var base_center_x: float = 0.0
var base_right_x: float = 0.0


# ─── Ready ───────────────────────────────────────────────────────────────────
func _ready() -> void:
	_setup_dots()
	_connect_buttons()
	await get_tree().process_frame
	_size_bg_glow()
	base_left_x = left_card.position.x
	base_center_x = center_card.position.x
	base_right_x = right_card.position.x
	_refresh_cards(false)
	_entrance_anim()

func _entrance_anim() -> void:
	modulate.a = 0.0
	var t: Tween = create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.38)

# ─── Setup ───────────────────────────────────────────────────────────────────
func _connect_buttons() -> void:
	prev_btn.pressed.connect(go_prev)
	next_btn.pressed.connect(go_next)

func _setup_dots() -> void:
	for c in dots_row.get_children():
		c.queue_free()
	dots.clear()
	for i in GAMES.size():
		var dot: ColorRect = ColorRect.new()
		# Dots expand horizontally to fill DotsRow — size_flags fill
		dot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		dot.custom_minimum_size = Vector2(10, 10)
		dot.color = Color(1, 1, 1, 0.20)
		dots_row.add_child(dot)
		dots.append(dot)

func _size_bg_glow() -> void:
	var vp: Vector2 = get_viewport_rect().size
	bg_glow.position = Vector2.ZERO
	bg_glow.size = vp

# ─── Card Population ──────────────────────────────────────────────────────────
func _refresh_cards(animate: bool = true) -> void:
	var li: int = wrapi(current_index - 1, 0, GAMES.size())
	var ri: int = wrapi(current_index + 1, 0, GAMES.size())

	_populate_card(left_card, GAMES[li], false, -1)
	_populate_card(center_card, GAMES[current_index], true,   0)
	_populate_card(right_card, GAMES[ri], false,  1)

	_animate_cards(animate)
	_refresh_dots()
	_update_bg_glow()

# direction: -1 = left card (go_prev on press), 0 = center (launch), 1 = right (go_next)
func _populate_card(card: Panel, game: Dictionary, is_center: bool, direction: int) -> void:
	var img_btn: TextureButton = card.get_node("MarginContainer/VBoxContainer/ImageButton") as TextureButton
	var info_btn: Button = card.get_node("MarginContainer/VBoxContainer/InfoButton")  as Button
	var title: Label = card.get_node("MarginContainer/VBoxContainer/GameInfo/GameTitle") as Label
	var desc: Label = card.get_node("MarginContainer/VBoxContainer/GameInfo/GameDesc")  as Label
	title.text = game["name"]
	title.add_theme_color_override("font_color", game["accent"])
	desc.text  = game["desc"]

	img_btn.texture_normal = game["image"]
	# All cards are enabled — side cards navigate, center launches
	img_btn.disabled       = false

	# ── Disconnect all old signals before reconnecting ──
	if img_btn.pressed.is_connected(_on_center_pressed):
		img_btn.pressed.disconnect(_on_center_pressed)
	if img_btn.pressed.is_connected(go_prev):
		img_btn.pressed.disconnect(go_prev)
	if img_btn.pressed.is_connected(go_next):
		img_btn.pressed.disconnect(go_next)
	if info_btn.pressed.is_connected(_on_info_pressed):
		info_btn.pressed.disconnect(_on_info_pressed)

	# ── Wire card image press ──
	if is_center:
		img_btn.pressed.connect(_on_center_pressed)
	elif direction == -1:
		img_btn.pressed.connect(go_prev)
	else:
		img_btn.pressed.connect(go_next)

	# ── Wire info button — always shows info for whichever game is on that card ──
	info_btn.pressed.connect(_on_info_pressed.bind(game["name"], card))

	# ── Style border ──
	var base: StyleBox = card.get_theme_stylebox("panel")
	if base:
		var s: StyleBoxFlat = base.duplicate() as StyleBoxFlat
		if s:
			if is_center:
				s.border_color = game["accent"]
				s.border_width_left = 3
				s.border_width_right = 3
				s.border_width_top = 3
				s.border_width_bottom = 3
				s.shadow_color = game["accent"] * Color(1, 1, 1, 0.5)
				s.shadow_size = 16
			else:
				s.border_color = Color(1, 1, 1, 0.06)
				s.border_width_left = 1
				s.border_width_right = 1
				s.border_width_top = 1
				s.border_width_bottom = 1
				s.shadow_size = 0
			card.add_theme_stylebox_override("panel", s)

func _animate_cards(animate: bool = true) -> void:
	var dur: float = ANIM_DURATION if animate else 0.001
	var offset: float = 340.0 * (CENTER_SCALE - SIDE_SCALE) / 2.5
	var shift: float = 20.0

	left_card.position.x   = base_left_x + shift
	center_card.position.x = base_center_x - offset + shift
	right_card.position.x  = base_right_x + shift

	_animate_card(left_card,   SIDE_SCALE,   0.35, dur)
	_animate_card(center_card, CENTER_SCALE, 1.0,  dur)
	_animate_card(right_card,  SIDE_SCALE,   0.35, dur)

func _animate_card(card: Panel, sc: float, alpha: float, dur: float) -> void:
	var t: Tween = create_tween()
	t.set_parallel(true)
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(card, "scale",      Vector2.ONE * sc, dur)
	t.tween_property(card, "modulate:a", alpha,            dur)

# ─── UI Updates ───────────────────────────────────────────────────────────────

func _update_bg_glow() -> void:
	var t: Tween = create_tween()
	t.tween_property(bg_glow, "color", GAMES[current_index]["glow"], ANIM_DURATION)

func _refresh_dots() -> void:
	for i in dots.size():
		var c: Color = GAMES[i]["accent"] if i == current_index else Color(1, 1, 1, 0.20)
		var t: Tween = create_tween()
		t.tween_property(dots[i], "color", c, 0.18)

# ─── Navigation ──────────────────────────────────────────────────────────────
func go_next() -> void:
	if is_animating:
		return
	is_animating = true
	current_index = wrapi(current_index + 1, 0, GAMES.size())
	_refresh_cards()
	await get_tree().create_timer(ANIM_DURATION).timeout
	is_animating = false

func go_prev() -> void:
	if is_animating:
		return
	is_animating = true
	current_index = wrapi(current_index - 1, 0, GAMES.size())
	_refresh_cards()
	await get_tree().create_timer(ANIM_DURATION).timeout
	is_animating = false

# ─── Input ────────────────────────────────────────────────────────────────────
func _gui_input(event: InputEvent) -> void:
	var is_touch: bool = event is InputEventScreenTouch
	var is_mouse: bool = event is InputEventMouseButton

	if is_touch or is_mouse:
		if event.pressed:
			dragging = true
			swipe_start = event.position
		else:
			if dragging:
				var delta: float = event.position.x - swipe_start.x
				if abs(delta) > 60:
					if delta < 0:
						go_next()
					else:
						go_prev()
			dragging = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("carousel_left"):  go_prev()
	if event.is_action_pressed("carousel_right"): go_next()

# ─── Scene Transitions ────────────────────────────────────────────────────────
func _on_center_pressed() -> void:
	_launch(GAMES[current_index]["scene"])

func _launch(scene_path: String) -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.20)
	await t.finished
	get_tree().change_scene_to_file(scene_path)

func _on_info_pressed(game_name: String, card: Panel) -> void:
	var g: Dictionary = GAMES.filter(func(x): return x["name"] == game_name)[0]
	var save_data: Dictionary = SaveManager.get_game(g["save_key"])

	var content: String = ""
	for key in g["stats"]:
		var label: String = key.replace("_", " ").capitalize()
		content += "%s: %s\n" % [label, save_data.get(key, 0)]

	var popup: PackedScene = preload("res://shared/info_popup.tscn")
	var instance: CanvasLayer = popup.instantiate()
	add_child(instance)
	instance.setup(game_name, content.strip_edges())
	
	var info_btn: Button = card.get_node("MarginContainer/VBoxContainer/InfoButton")
	instance.set_position_near(info_btn.global_position + Vector2(10, 0))
