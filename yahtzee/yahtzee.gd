extends Control

var difficulties = ["Easy", "Medium", "Hard"]
var selected_diff = "Medium"
var is_player_turn = true

func _ready():
	#start screen
	$StartScreen.visible = true
	$GameScreen.visible = false
	
	$StartScreen/Container/VBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)
	#difficulty section of home screen 13-15
	$StartScreen/Container/VBoxContainer/DifficultyValueLabel.text= "Medium"
	$StartScreen/Container/VBoxContainer/DifficultyValueLabel.modulate = GameColors.YELLOW
	$StartScreen/Container/VBoxContainer/HSlider.value_changed.connect(_on_slider_changed)
	
	$StartScreen/Container/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	#end of start screen

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_slider_changed(value: float):
	selected_diff = difficulties[int(value)]
	$StartScreen/Container/VBoxContainer/DifficultyValueLabel.text = selected_diff
	#label color change per level
	match selected_diff:
		"Easy": $StartScreen/Container/VBoxContainer/DifficultyValueLabel.modulate = GameColors.SPOTIFY_GREEN
		"Medium": $StartScreen/Container/VBoxContainer/DifficultyValueLabel.modulate = GameColors.YELLOW
		"Hard": $StartScreen/Container/VBoxContainer/DifficultyValueLabel.modulate = GameColors.RED
	
func _on_play_pressed():
	$StartScreen.visible = false
	$GameScreen.visible = true
	
func start_game():
	$GameScreen/DiceManager.reset_turn()
	
	
func update_dice_ui():
	var dice = $GameScreen/DiceManager.dice
	var held = $GameScreen/DiceManager.held_dice
	for i in range(5):
		var die = $GameScreen/VBoxContainer/DiceRow.get_child(i)
		die.text = str(dice[i])
		die.modulate = GameColors.YELLOW if held[i] else GameColors.IVORY
		
func update_roll_btn():
	var button = $GameScreen/VBoxContainer/BottomBar/RollButton
	var rolls = $GameScreen/DiceManager.rolls_left
	if is_player_turn:
		button.text = "Roll"
		button.disabled = false
		button.modulate = GameColors.YALE_BLUE
	else:
		button.text = "Bot Turn..."
		button.disabled = true
		button.modulate = GameColors.ASH_GREY
