extends Node
class_name GameStateManager
@onready var MovementManager = $Background2/MovementManager
@onready var SpawnManager = $Background2/SpawnManager
@onready var game_over_ui = $Background2/GameOverScreen

var options_scene = preload("res://shared/options_menu.tscn")
var end_scene = preload("res://snake/components/ui/end_screen.tscn")

var game_active: bool = true
var score: int

func _ready() -> void:
	score = 0
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	MovementManager.generate_snake()
	SpawnManager.spawn_food()

#Current direction & Next Direction
var current_dir = Vector2i.RIGHT
var next_dir = Vector2i.RIGHT
func _input(event: InputEvent) -> void:
	next_dir = MovementManager.change_dir(event, current_dir)
	
func _on_move_timer_timeout():
	# 1. Get current info
	current_dir = next_dir
	var current_head = MovementManager.get_head_pos()
	var next_pos = current_head + current_dir
	
	# 2. Check collisions
	var collision = MovementManager.check_collision(next_pos, MovementManager.body_coords)
	
	# 3. Act based on result
	match collision:
		"none":
			MovementManager.move_snake(next_pos, false)
		"consumable":
			MovementManager.move_snake(next_pos, true)
			#Score
			score+=1
			$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
			SpawnManager.spawn_food()
		"wall":
			handle_game_over("WALL")
		"self":
			handle_game_over("SELF")
		#powerup:

#Game over state
func handle_game_over(reason: String):
	if not game_active: return # Prevent multiple triggers
	
	game_active = false
	print("Game Over! Reason: ", reason)
	
	$MoveTimer.stop()
	print("timer stopped")
	
	#update scores
	var snake = SaveManager.get_game("snake")
	var new_high_score = int(max(score, snake["high_score"]))
	
	SaveManager.update_game("snake", {
		"high_score": new_high_score,
		"games_played": snake["games_played"] + 1
	})
	
	SaveManager._save()
	print("saved: ", SaveManager.get_game("snake"))
	
	show_game_over_screen(new_high_score)
	
func show_game_over_screen(new_high_score: int):
	var game_over_ui = end_scene.instantiate()
	add_child(game_over_ui)
	game_over_ui.setup(
		score,
		new_high_score
	)

# Connect the Button's "pressed" signal to this function
func _on_restart_button_pressed():
	# Reloads the current scene to start fresh
	print("scene reload")
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func _on_back_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
	

#Pause state
func _on_options_button_pressed() -> void:
	var options_menu = options_scene.instantiate()
	options_menu.process_mode = Node.PROCESS_MODE_ALWAYS # so it doesn't get paused as well
	options_menu.resume_requested.connect(_on_resume)
	add_child(options_menu)
	get_tree().paused = true

func _on_resume() -> void:
	if game_over_ui.visible:
		get_tree().paused = false
		return
	get_tree().paused = false
	$MoveTimer.stop()
	var countdown_label = $UnpauseTimer 
	for i in range(3, 0, -1):
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0, false, false, true).timeout
	countdown_label.text = ""
	$MoveTimer.start(0.1)
	
