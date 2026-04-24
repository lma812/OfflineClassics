extends Control

var difficulties = ["Easy", "Medium", "Hard"]
var selected_diff = "Medium"

# Called when the node enters the scene tree for the first time.
func _ready():
	#var style = StyleBoxFlat.new()
	#style.bg_color = GameColors.YALE_BLUE
	#$Control/VBoxContainer/BackButton.add_theme_stylebox_override("normal", style)
	
	$StartScreen/Container/VBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)
	$StartScreen.visible = true
	$StartScreen/Container/VBoxContainer/DifficultyValueLabel.text= "Medium"
	$StartScreen/Container/VBoxContainer/DifficultyValueLabel.modulate = GameColors.YELLOW
	
	$StartScreen/Container/VBoxContainer/HSlider.value_changed.connect(_on_slider_changed)
	$StartScreen/Container/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	




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
	


	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
