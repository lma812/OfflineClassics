extends Node

var player_scorecard = {
	"ones": null, "twos": null, "threes": null,
	"fours": null, "fives": null, "sixes": null,
	"three_of_kind": null, "four_of_kind": null,
	"full_house": null, "small_straight": null,
	"large_straight": null, "yahtzee": null
}

var bot_scorecard = {
	"ones": null, "twos": null, "threes": null,
	"fours": null, "fives": null, "sixes": null,
	"three_of_kind": null, "four_of_kind": null,
	"full_house": null, "small_straight": null,
	"large_straight": null, "yahtzee": null
}

func has_n_of_a_kind(dices: Array, n: int) ->bool:
	var counts = get_counts(dices)
	for count in counts.values():
		if count >= n:
			return true
	return false

func get_counts(dices: Array) -> Dictionary:
	var counts = {}
	for dice in dices:
		#default is 0
		counts[dice] = counts.get(dice,0) + 1
	return counts
	
func get_unique(dices: Array) -> Array:
	var unique = []
	for dice in dices:
		if not dice in unique:
			unique.append(dice)
	return unique
	
func reset():
	for key in player_scorecard:
		player_scorecard[key] = null
	for key in bot_scorecard:
		bot_scorecard[key] = null



func calc_one_to_six(dices: Array, number: int) -> int:
	var total = 0
	for dice in dices:
		if dice == number:
			total += dice
	return total
	
func calc_three_kind(dices: Array) -> int:
	if has_n_of_a_kind(dices, 3):
		return dices.reduce( func(a,b): return a+b)
	return 0

func calc_four_kind(dices: Array) -> int:
	if has_n_of_a_kind(dices, 4):
		return dices.reduce( func(a,b): return a+b)
	return 0

func calc_full_house(dices:Array) -> int:
	var counts = get_counts(dices)
	var vals = counts.values()
	if 2 in vals and 3 in vals:
		return 25
	return 0
	
func calc_small_straight(dices: Array) -> int:
	var unique = get_unique(dices)
	unique.sort()
	var straights = [[1,2,3,4], [2,3,4,5],  [3,4,5,6]]
	# all() loops through every element in s and runs the func on it
	for straight in straights:
		if straight.all(func(n): return n in unique):
			return 30
	return 0
	
func calc_large_straight(dices: Array) -> int:
	var unique = get_unique(dices)
	unique.sort()
	if unique == [1,2,3,4,5] or unique == [2,3,4,5,6]:
		return 40
	return 0

func calc_yahtzee(dice: Array) -> int:
	if has_n_of_a_kind(dice, 5):
		return 50
	return 0
	
	
# Show potential scores before claiming (for user convience)

func get_poten_score(category: String, dices: Array) -> int:
	match category:
		"ones": return calc_one_to_six(dices, 1)
		"twos": return calc_one_to_six(dices, 2)
		"threes": return calc_one_to_six(dices, 3)
		"fours": return calc_one_to_six(dices, 4)
		"fives": return calc_one_to_six(dices, 5)
		"sixes": return calc_one_to_six(dices, 6)
		"three_of_kind": return calc_three_kind(dices)
		"four_of_kind": return calc_four_kind(dices)
		"full_house": return calc_full_house(dices)
		"small_straight": return calc_small_straight(dices)
		"large_straight": return calc_large_straight(dices)
		"yahtzee": return calc_yahtzee(dices)
	return 0
		
func claim_player_score(category: String, dice: Array) -> int:
	if player_scorecard[category] != null:
		return -1  # already claimed
	var score = get_poten_score(category, dice)
	player_scorecard[category] = score
	return score

func claim_bot_score(category: String, dice: Array) -> int:
	if bot_scorecard[category] != null:
		return -1
	var score = get_poten_score(category, dice)
	bot_scorecard[category] = score
	return score
		
		
func get_total(scorecard: Dictionary) -> int:
	var total=0
	for val in scorecard.values():
		if val != null:
			total += val
	return total

func get_player_total() -> int: 
	return get_total(player_scorecard)
	
func get_bot_total() -> int: 
	return get_total(bot_scorecard)
	
func game_over() -> bool: 
	for val in player_scorecard.values():
		if val == null:
			return false
	for val in bot_scorecard.values():
		if val == null:
			return false
	return true
