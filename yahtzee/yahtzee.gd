extends Control

var difficulties = ["Easy", "Medium", "Hard"]
var selected_diff = "Medium"
var is_player_turn = true

func _ready():
	#start screen
	$StartScreen.visible = true
	$GameScreen.visible = false
	$GameScreen/GameOverScreen.visible = false
	
	$StartScreen/Container/VBoxContainer/BackButton.pressed.connect(on_back_button_pressed)
	$GameScreen/VBoxContainer/TopBar/BackButton.pressed.connect(game_back_button_pressed)
	$GameScreen/VBoxContainer/TopBar/RestartButton.pressed.connect(restart_button_pressed)
	$GameScreen/GameOverScreen/Container/Restart.pressed.connect(restart_button_pressed)
	$GameScreen/GameOverScreen/Container/BacktoMenu.pressed.connect(on_back_button_pressed)
	
	#difficulty section of home screen
	$StartScreen/Container/VBoxContainer/DifficultyValueLabel.text= "Medium"
	$StartScreen/Container/VBoxContainer/DifficultyValueLabel.modulate = GameColors.YELLOW
	$StartScreen/Container/VBoxContainer/HSlider.value_changed.connect(_on_slider_changed)
	
	$StartScreen/Container/VBoxContainer/PlayButton.pressed.connect(on_play_pressed)
	#end of start screen
	
func _on_slider_changed(value: float):
	selected_diff = difficulties[int(value)]
	$StartScreen/Container/VBoxContainer/DifficultyValueLabel.text = selected_diff
	#label color change per level
	match selected_diff:
		"Easy": $StartScreen/Container/VBoxContainer/DifficultyValueLabel.modulate = GameColors.SPOTIFY_GREEN
		"Medium": $StartScreen/Container/VBoxContainer/DifficultyValueLabel.modulate = GameColors.YELLOW
		"Hard": $StartScreen/Container/VBoxContainer/DifficultyValueLabel.modulate = GameColors.RED

func start_game():
	$GameScreen/DiceManager.reset_turn()
	$GameScreen/ScoreManager.reset()
	$GameScreen/BotEngine.set_difficulty(selected_diff)
	$GameScreen/BotEngine.dice_rolled.connect(update_dice_ui)
	$GameScreen/VBoxContainer/BottomBar/RollButton.pressed.connect(on_roll_pressed)
	connect_score_cells()
	for i in range(5):
		var die = $GameScreen/VBoxContainer/DiceRow.get_child(i)
		var index = i
		die.pressed.connect( func(): on_die_pressed(index))
		
	update_dice_ui()
	update_rolls_ui()
	update_roll_btn()
	update_score_header()

func connect_score_cells():
	#maps each player button node to its category string
	var cells = {
		"OnesPlayer": "ones",
		"TwosPlayer": "twos",
		"ThreesPlayer": "threes",
		"FoursPlayer": "fours",
		"FivesPlayer": "fives",
		"SixesPlayer": "sixes",
		"ThreeOfKindPlayer": "three_of_kind",
		"FourOfKindPlayer": "four_of_kind",
		"FullHousePlayer": "full_house",
		"SmallStraightPlayer": "small_straight",
		"LargeStraightPlayer": "large_straight",
		"YahtzeePlayer": "yahtzee"
	}
	for names in cells:
		var category = cells[names]
		var button = $GameScreen/VBoxContainer/ScoreGrid.get_node(names)
		button.pressed.connect( func(): on_score_cell_pressed(category))

# player actions
func on_roll_pressed():
	$GameScreen/DiceManager.roll()
	update_dice_ui()
	update_rolls_ui()
	update_roll_btn()
	update_poten_scores()

func on_die_pressed(index : int):
	$GameScreen/DiceManager.toggle_hold(index)
	update_dice_ui()

func on_score_cell_pressed(category: String):
	if not is_player_turn:
		return
	if $GameScreen/DiceManager.rolls_left == 3:
		return
	var dice = $GameScreen/DiceManager.dice
	var result = $GameScreen/ScoreManager.claim_player_score(category, dice)
	if result == -1:
		return
	
	update_score_cell(category, result)
	update_score_header()
	clear_potential_scores()
	
	if $GameScreen/ScoreManager.game_over():
		show_game_over()
		return
	
	#switch to bot turn
	is_player_turn = false
	update_roll_btn()
	$GameScreen/DiceManager.reset_turn()
	update_rolls_ui()
	
	await get_tree().create_timer(1.0).timeout
	bot_take_turn()

func bot_take_turn():
	$GameScreen/DiceManager.reset_turn()
	update_rolls_ui()
	update_dice_ui()
	
	await $GameScreen/BotEngine.take_turn($GameScreen/DiceManager, $GameScreen/ScoreManager)
	#print("Bot dice: ", $GameScreen/DiceManager.dice)
	#print("Bot scorecard: ", $GameScreen/ScoreManager.bot_scorecard)
	update_bot_score_cells()
	update_score_header()
	if $GameScreen/ScoreManager.game_over():
		show_game_over()
		return
	is_player_turn = true
	$GameScreen/DiceManager.reset_turn()
	update_dice_ui()
	update_rolls_ui()
	update_roll_btn()


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
	if not is_player_turn:
		button.text = "Bot Turn..."
		button.disabled = true
	else:
		button.text = "Roll"
		button.disabled = rolls <= 0

func update_rolls_ui():
	var rolls = $GameScreen/DiceManager.rolls_left
	$GameScreen/VBoxContainer/BottomBar/Roll1.modulate = GameColors.SOFT_LINEN if rolls >= 1 else GameColors.ASH_GREY
	$GameScreen/VBoxContainer/BottomBar/Roll2.modulate = GameColors.SOFT_LINEN if rolls >= 2 else GameColors.ASH_GREY
	$GameScreen/VBoxContainer/BottomBar/Roll3.modulate = GameColors.SOFT_LINEN if rolls >= 3 else GameColors.ASH_GREY

func update_score_header():
	var player_total = $GameScreen/ScoreManager.get_player_total()
	var bot_total = $GameScreen/ScoreManager.get_bot_total()
	$GameScreen/VBoxContainer/TopBar/Label/GridContainer/HBoxContainer/PlayerScore.text = str(player_total)
	$GameScreen/VBoxContainer/TopBar/Label/GridContainer/HBoxContainer/BotScore.text = str(bot_total)

func update_score_cell(category: String, score: int):
	#mapping category back to node name
	var names = {
		"ones": "OnesPlayer",
		"twos": "TwosPlayer",
		"threes": "ThreesPlayer",
		"fours": "FoursPlayer",
		"fives": "FivesPlayer",
		"sixes": "SixesPlayer",
		"three_of_kind": "ThreeOfKindPlayer",
		"four_of_kind": "FourOfKindPlayer",
		"full_house": "FullHousePlayer",
		"small_straight": "SmallStraightPlayer",
		"large_straight": "LargeStraightPlayer",
		"yahtzee": "YahtzeePlayer"
	}
	var button = $GameScreen/VBoxContainer/ScoreGrid.get_node(names[category])
	button.text = str(score)
	button.disabled = true
	var style = button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	style.bg_color = GameColors.ASH_GREY
	button.add_theme_stylebox_override("normal", style)

func update_bot_score_cells():
	var names = {
		"ones": "OnesBot",
		"twos": "TwosBot",
		"threes": "ThreesBot",
		"fours": "FoursBot",
		"fives": "FivesBot",
		"sixes": "SixesBot",
		"three_of_kind": "ThreeOfKindBot",
		"four_of_kind": "FourOfKindBot",
		"full_house": "FullHouseBot",
		"small_straight": "SmallStraightBot",
		"large_straight": "LargeStraightBot",
		"yahtzee": "YahtzeeBot"
	}
	var scorecard = $GameScreen/ScoreManager.bot_scorecard
	for category in names:
		if scorecard[category] != null:
			var label = $GameScreen/VBoxContainer/ScoreGrid.get_node(names[category])
			label.text = str(scorecard[category])

func update_poten_scores():
	var dice = $GameScreen/DiceManager.dice
	var scorecard = $GameScreen/ScoreManager.player_scorecard
	var names = {
		"ones": "OnesPlayer",
		"twos": "TwosPlayer",
		"threes": "ThreesPlayer",
		"fours": "FoursPlayer",
		"fives": "FivesPlayer",
		"sixes": "SixesPlayer",
		"three_of_kind": "ThreeOfKindPlayer",
		"four_of_kind": "FourOfKindPlayer",
		"full_house": "FullHousePlayer",
		"small_straight": "SmallStraightPlayer",
		"large_straight": "LargeStraightPlayer",
		"yahtzee": "YahtzeePlayer"
	}
	for category in names:
		var button = $GameScreen/VBoxContainer/ScoreGrid.get_node(names[category])
		if scorecard[category] != null:
			continue
		var potential = $GameScreen/ScoreManager.get_poten_score(category, dice)
		if potential > 0:
			button.text = str(potential)
		else:
			button.text = "0"

func clear_potential_scores():
	var names = {
		"ones": "OnesPlayer",
		"twos": "TwosPlayer",
		"threes": "ThreesPlayer",
		"fours": "FoursPlayer",
		"fives": "FivesPlayer",
		"sixes": "SixesPlayer",
		"three_of_kind": "ThreeOfKindPlayer",
		"four_of_kind": "FourOfKindPlayer",
		"full_house": "FullHousePlayer",
		"small_straight": "SmallStraightPlayer",
		"large_straight": "LargeStraightPlayer",
		"yahtzee": "YahtzeePlayer"
	}
	var scorecard = $GameScreen/ScoreManager.player_scorecard
	for category in names:
		# only clear if NOT yet claimed
		if scorecard[category] == null:
			var button = $GameScreen/VBoxContainer/ScoreGrid.get_node(names[category])
			button.text = ""
			
#nav
func on_back_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func game_back_button_pressed():
	$StartScreen.visible = true
	$GameScreen.visible = false

func on_play_pressed():
	$StartScreen.visible = false
	$GameScreen.visible = true
	start_game()
	
func show_game_over():
	var player_total = $GameScreen/ScoreManager.get_player_total()
	var bot_total = $GameScreen/ScoreManager.get_bot_total()
	$GameScreen/GameOverScreen.visible = true
	if player_total > bot_total:
		$GameScreen/GameOverScreen/Container/GameOver.text = "YOU WIN!"
	else:
		$GameScreen/GameOverScreen/Container/GameOver.text = "YOU LOSE!"
	$GameScreen/GameOverScreen/Container/Reason.text = "YOU: " + str(player_total) + " VS BOT: " + str(bot_total)
	SaveManager.record_yahtzee_result(player_total > bot_total)
	var wins = SaveManager.get_game("yahtzee")["high_score"]
	$GameScreen/GameOverScreen/Container/Highscore.text = "WINS: " + str(wins)
	
func restart_button_pressed():
	#reset game
	$GameScreen/GameOverScreen.visible = false
	$GameScreen/DiceManager.reset_turn()
	$GameScreen/ScoreManager.reset()
	is_player_turn = true
	var names = [
		"OnesPlayer", "TwosPlayer", "ThreesPlayer",
		"FoursPlayer", "FivesPlayer", "SixesPlayer",
		"ThreeOfKindPlayer", "FourOfKindPlayer",
		"FullHousePlayer", "SmallStraightPlayer",
		"LargeStraightPlayer", "YahtzeePlayer"
	]
	var bot_names = [
		"OnesBot", "TwosBot", "ThreesBot",
		"FoursBot", "FivesBot", "SixesBot",
		"ThreeOfKindBot", "FourOfKindBot",
		"FullHouseBot", "SmallStraightBot",
		"LargeStraightBot", "YahtzeeBot"
	]
	for node_name in names:
		var button = $GameScreen/VBoxContainer/ScoreGrid.get_node(node_name)
		button.text = ""
		button.disabled = false
		var style = button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
		style.bg_color = "#75c4ff"
		button.add_theme_stylebox_override("normal", style)
	for node_name in bot_names:
		var label = $GameScreen/VBoxContainer/ScoreGrid.get_node(node_name)
		label.text = ""

	# reset score header
	update_score_header()

	# reset dice ui
	update_dice_ui()
	update_rolls_ui()
	update_roll_btn()
	
