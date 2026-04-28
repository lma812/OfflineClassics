extends Node2D
class_name MovementManager
@onready var SpawnManager = $"../SpawnManager"
@export var segment_scene: PackedScene # Link your snake_segment.tscn here

const GRID_WIDTH = 18
const GRID_HEIGHT = 20
const CELL_SIZE = 32

var body_coords: Array
var body_segments: Array

#Starting Instance
func generate_snake() -> void:
	var start_x = int(GRID_WIDTH / 2)
	var start_y = int(GRID_HEIGHT / 2)
	
	# 3. Initialize the array 
	body_coords = [
		Vector2i(start_x, start_y), 
		Vector2i(start_x - 1, start_y), 
		Vector2i(start_x - 2, start_y)
	]

	# Clear any existing segments (safety first)
	for segment in body_segments:
		segment.queue_free()
	body_segments.clear()
	
	# Create a visual segment for every coordinate in our starting array
	for coord in body_coords:
		var new_seg = segment_scene.instantiate()
		add_child(new_seg)
		body_segments.append(new_seg)
		
		# Position it immediately
		new_seg.position = coord * CELL_SIZE
		
#Getter for head
func get_head_pos() -> Vector2i:
	return body_coords[0]

#Direction Change
func change_dir(event: InputEvent, current_dir: Vector2i)-> Vector2i:
	if event.is_action_pressed("move_up") and current_dir != Vector2i.DOWN:
		return Vector2i.UP
	if event.is_action_pressed("move_down") and current_dir != Vector2i.UP:
		return Vector2i.DOWN
	if event.is_action_pressed("move_left") and current_dir != Vector2i.RIGHT:
		return Vector2i.LEFT
	if event.is_action_pressed("move_right") and current_dir != Vector2i.LEFT:
		return Vector2i.RIGHT
	return current_dir

#Check Collision
func check_collision(next_head_pos: Vector2i, snake_body: Array) -> String:
	# Wall Collision
	if  next_head_pos.x < 0 or next_head_pos.x >= GRID_WIDTH:
		return "wall"
	if next_head_pos.y < 0 or next_head_pos.y >= GRID_HEIGHT:
		return "wall"
	# Self Collision 
	if next_head_pos in snake_body:
		return "self"
	# Cross food/powerup	
	if next_head_pos == SpawnManager.food_pos:
		return "consumable"
	
	return "none"



#Move
func move_snake(next_pos: Vector2i, has_eaten: bool):
	print("Snake Head Coordinate: ", next_pos)
	# 1. Add the new head position to the front
	body_coords.insert(0, next_pos)
	
	# 2. If we didn't eat food, remove the tail
	if not has_eaten:
		body_coords.pop_back()
	else:
		# If we ate, create a new visual segment
		var new_seg = segment_scene.instantiate()
		add_child(new_seg)
		body_segments.append(new_seg)

	# 3. Update Visuals
	for i in range(body_coords.size()):
		# Move the head and all body segments to their new pixel positions
		# (Grid coordinate * 32px tile size)
		if i < body_segments.size(): # Safety check
			body_segments[i].position = body_coords[i] * CELL_SIZE
