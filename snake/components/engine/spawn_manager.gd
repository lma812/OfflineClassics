extends Node2D
@onready var MovementManager = $"../MovementManager"

var regen_food: bool = true
var food_pos: Vector2i

func spawn_food():
	regen_food = true
	while(regen_food):
		regen_food = false
		food_pos = Vector2i(randi_range(0, MovementManager.GRID_WIDTH-1), randi_range(0, MovementManager.GRID_HEIGHT-1))
		print(food_pos)
		for i in MovementManager.body_coords:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * MovementManager.CELL_SIZE) 
	print($Food.position)
