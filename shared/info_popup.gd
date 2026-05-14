extends CanvasLayer

@onready var title_label = $Panel/MarginContainer/VBoxContainer/Title
@onready var content_label = $Panel/MarginContainer/VBoxContainer/Content
@onready var close_button = $Panel/MarginContainer/VBoxContainer/CloseButton

func _ready() -> void:
	close_button.pressed.connect(queue_free)
	
func set_position_near(pos: Vector2) -> void:
	$Panel.global_position = pos

func setup(title: String, content: String) -> void:
	title_label.text = title
	content_label.text = content

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		queue_free()
	if event is InputEventScreenTouch and event.pressed:
		queue_free()
