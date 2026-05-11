extends Node

@onready var grid_manager = $"../GridManager"

var pending_score := 0

func move(direction: Vector2) -> bool:
	var moved := false
	pending_score = 0

	if direction == Vector2.LEFT:
		for row in range(grid_manager.GRID_SIZE):
			var result = merge_row(grid_manager.grid[row])
			if result != grid_manager.grid[row]:
				moved = true
			grid_manager.grid[row] = result

	elif direction == Vector2.RIGHT:
		for row in range(grid_manager.GRID_SIZE):
			var reversed = grid_manager.grid[row].duplicate()
			reversed.reverse()
			var result = merge_row(reversed)
			result.reverse()
			if result != grid_manager.grid[row]:
				moved = true
			grid_manager.grid[row] = result

	elif direction == Vector2.UP:
		for col in range(grid_manager.GRID_SIZE):
			var column := []
			for row in range(grid_manager.GRID_SIZE):
				column.append(grid_manager.grid[row][col])

			var result = merge_row(column)

			for row in range(grid_manager.GRID_SIZE):
				if grid_manager.grid[row][col] != result[row]:
					moved = true
				grid_manager.grid[row][col] = result[row]

	elif direction == Vector2.DOWN:
		for col in range(grid_manager.GRID_SIZE):
			var column := []
			for row in range(grid_manager.GRID_SIZE):
				column.append(grid_manager.grid[row][col])

			column.reverse()
			var result = merge_row(column)
			result.reverse()

			for row in range(grid_manager.GRID_SIZE):
				if grid_manager.grid[row][col] != result[row]:
					moved = true
				grid_manager.grid[row][col] = result[row]

	if moved:
		grid_manager.score += pending_score
		grid_manager.spawn_tile()
		grid_manager.update_visuals()

	return moved

func merge_row(row: Array) -> Array:
	var compressed := []
	for val in row:
		if val != 0:
			compressed.append(val)

	var merged := []
	var i := 0

	while i < compressed.size():
		if i + 1 < compressed.size() and compressed[i] == compressed[i + 1]:
			var new_val = compressed[i] * 2
			pending_score += new_val
			merged.append(new_val)
			i += 2
		else:
			merged.append(compressed[i])
			i += 1

	while merged.size() < grid_manager.GRID_SIZE:
		merged.append(0)

	return merged
