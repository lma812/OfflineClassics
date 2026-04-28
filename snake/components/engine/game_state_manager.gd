extends Node
class_name GameStateManager
@onready var MovementManager = $MovementManager
@onready var SpawnManager = $SpawnManager
@onready var game_over_ui = $GameOverScreen


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
			score+=1
			$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
			SpawnManager.spawn_food()
		"wall", "self":
			handle_game_over("wall or something")

#Score

#Food/powerup positions

#Game over state
func handle_game_over(reason: String):
	if not game_active: return # Prevent multiple triggers
	
	game_active = false
	print("Game Over! Reason: ", reason)
	
	# 1. Stop the movement
	$MoveTimer.stop()
	print("timer stopped")
	
	# 2. Show the UI 
	show_game_over_screen(reason)
	
func show_game_over_screen(reason: String):
	game_over_ui.show()
	# Update the label to say why they died
	game_over_ui.get_node("VBoxContainer/Label").text = "GAME OVER\nHit " + reason

# Connect the Button's "pressed" signal to this function
func _on_restart_button_pressed():
	# Reloads the current scene to start fresh
	print("scene reload")
	get_tree().reload_current_scene()
	
#Pause state
