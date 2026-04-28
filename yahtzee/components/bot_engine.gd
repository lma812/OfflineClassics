extends Node
signal dice_rolled
var difficulty = "Meidum"

func set_difficulty(diff: String):
	difficulty = diff
	
func take_turn(dice_manager, score_manager) -> String:
	match difficulty:
		"Easy" : return await easy_turn(dice_manager, score_manager)
		"Medium" : return await medium_turn(dice_manager, score_manager)
		"Hard" : return await hard_turn(dice_manager, score_manager)
	return ""

func get_counts(dice: Array) -> Dictionary:
	var counts = {}
	for d in dice:
		counts[d] = counts.get(d, 0) + 1
	return counts

func hold_best_dice(dice_manager) -> void:
	var dice = dice_manager.dice
	var counts = get_counts(dice)
	var best_val = -1
	var best_count = 0
	# finds highest dice and holds all of that #
	for val in counts:
		if counts[val] > best_count:
			best_count = counts[val]
			best_val = val
	for i in range(5):
		dice_manager.held_dice[i] = (dice[i] == best_val)

func pick_best_category(dice: Array, score_manager) -> String:
	var best_category = ""
	var best_score = -1

	for category in score_manager.bot_scorecard:
		if score_manager.bot_scorecard[category] != null:
			continue
		var potential = score_manager.get_poten_score(category, dice)
		if potential > best_score:
			best_score = potential
			best_category = category

	# if everything scores 0 just pick first unclaimed
	if best_category == "" or best_score == 0:
		for category in score_manager.bot_scorecard:
			if score_manager.bot_scorecard[category] == null:
				return category

	return best_category






# EASY MODE
# 3 rolls but cant hold dice

func easy_turn(dice_manager, score_manager) -> String:
	while dice_manager.rolls_left > 0:
		dice_manager.held_dice = [false, false, false, false, false]
		dice_manager.roll()
		emit_signal("dice_rolled")
		#print("After roll, rolls left: ", dice_manager.rolls_left)
		await get_tree().create_timer(0.8).timeout
		
	var category = pick_best_category(dice_manager.dice, score_manager)
	score_manager.claim_bot_score(category, dice_manager.dice)
	return category
	
	# MEDIUM MODE
	# 2 rolls max, can hold but only holds highest dice
	
func medium_turn(dice_manager, score_manager) -> String:
	# first roll — always rolls
	dice_manager.roll()
	emit_signal("dice_rolled")
	#print("After roll, rolls left: ", dice_manager.rolls_left)
	await get_tree().create_timer(0.8).timeout

	# hold best dice after first roll
	if dice_manager.rolls_left > 0:
		hold_best_dice(dice_manager)
		dice_manager.roll()
		#print("After roll, rolls left: ", dice_manager.rolls_left)
		emit_signal("dice_rolled")
		await get_tree().create_timer(0.8).timeout

	var category = pick_best_category(dice_manager.dice, score_manager)
	score_manager.claim_bot_score(category, dice_manager.dice)
	return category
	
	# HARD MODE
	# rolls normally, can hold
func hard_turn(dice_manager, score_manager) -> String:
	while dice_manager.rolls_left > 0:
		dice_manager.roll()
		#print("After roll, rolls left: ", dice_manager.rolls_left)
		emit_signal("dice_rolled")
		await get_tree().create_timer(0.8).timeout
		if dice_manager.rolls_left > 0:
			hold_best_dice(dice_manager)
			
	var category = pick_best_category(dice_manager.dice, score_manager)
	score_manager.claim_bot_score(category, dice_manager.dice)
	return category
	
	
	
