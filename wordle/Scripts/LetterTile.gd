extends Panel

@onready var label = $Label

func set_letter(letter: String) -> void:
	label.text = letter

func clear() -> void:
	label.text = ""

func set_state(state: String) -> void:
	var style = get_theme_stylebox("panel").duplicate()

	match state:
		"correct":
			style.bg_color = Color("6aaa64")
			style.border_color = Color("6aaa64")
		"present":
			style.bg_color = Color("c9b458")
			style.border_color = Color("c9b458")
		"absent":
			style.bg_color = Color("3a3a3c")
			style.border_color = Color("3a3a3c")

	add_theme_stylebox_override("panel", style)
