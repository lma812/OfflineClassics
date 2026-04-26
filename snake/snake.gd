extends Control
#const COLORS = preload("res://shared/theme/colors.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(COLORS)
	#print(COLORS.primary)
	#$BacktoMenu.modulate = COLORS.primary
	$Menu/BacktoMenu.pressed.connect(_on_back_button_pressed)
	
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
