extends Node

@onready var KeyboardManager = $KeyboardManager
@onready var input_label = $CenterContainer/VBoxContainer/Guess

var current_input := ""

func _ready() -> void:
	KeyboardManager.create_keyboard()
	KeyboardManager.letter_pressed.connect(_on_letter)
	KeyboardManager.backspace_pressed.connect(_on_backspace)
	KeyboardManager.enter_pressed.connect(_on_enter)
	
func _on_backspace() -> void:
	if current_input.length() > 0:
		current_input = current_input.substr(0, current_input.length() - 1)
		input_label.text = current_input

func _on_letter(key:String) -> void:
	if current_input.length() < 30:
		current_input += key
		input_label.text = current_input

func _on_enter() -> void:
	emit_signal("enter_pressed", current_input)
