extends Node

var dice = [1, 1, 1, 1, 1]
var held_dice = [false, false, false, false, false]
var rolls_left= 3

func roll():
	if rolls_left <= 0:
		return
	for i in range(5):
		if not held_dice[i]:
			dice[i] = randi_range(1, 6)
	rolls_left -= 1
		

func toggle_hold(index : int):
	if rolls_left == 3:
		return
	held_dice[index] = !held_dice[index]
	
func reset_turn():
	held_dice = [false, false, false, false, false]
	rolls_left = 3
