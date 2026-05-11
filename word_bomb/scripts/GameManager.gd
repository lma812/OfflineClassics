extends Node
@onready var KeyboardManager = $KeyboardManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	KeyboardManager.create_keyboard()
	KeyboardManager._on_letter.connect(letter_pressed)
	KeyboardManager..connect(_on_letter)
	KeyboardManager.backspace_pressed.connect(_on_backspace)
	KeyboardManager.enter_pressed.connect(_on_enter)
