extends Node

var elapsed_time := 0.0
var score_label: Label
var timer_label: Label

func _ready() -> void:
	var vbox = get_parent().get_node("CenterContainer/VBoxContainer")
	
	score_label = vbox.get_node("ScoreRow/ScoreLabel")
	timer_label = vbox.get_node("ScoreRow/TimerLabel")
	
	vbox.get_node("TitleRow/OptionsButton").pressed.connect(func():
		get_parent().get_node("GameStateManager").show_options()
	)

func update_score(new_score: int) -> void:
	score_label.text = "SCORE: " + str(new_score)

func _process(delta: float) -> void:
	if timer_label == null:
		return
	
	elapsed_time += delta
	
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	
	timer_label.text = "TIME: %d:%02d" % [minutes, seconds]
