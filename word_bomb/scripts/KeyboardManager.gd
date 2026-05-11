extends Node

signal letter_pressed(letter: String)
signal backspace_pressed
signal enter_pressed

var keyboard_buttons = {}

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_BACKSPACE:
			backspace_pressed.emit()
			return

		if event.keycode == KEY_ENTER:
			enter_pressed.emit()
			return

		var text = event.as_text().to_upper()

		if text.length() == 1 and text >= "A" and text <= "Z":
			letter_pressed.emit(text)

func create_keyboard() -> void:
	var keyboard = get_parent().get_node("CenterContainer/VBoxContainer/KeyboardContainer")

	var rows = [
	["Q","W","E","R","T","Y","U","I","O","P"],
	["A","S","D","F","G","H","J","K","L","⌫"],
	["Z","X","C","V","B","N","M","ENTER"]
]

	for row_index in range(rows.size()):
		var row_container = keyboard.get_node("Row" + str(row_index + 1))

		for key in rows[row_index]:
			var button = Button.new()

			button.text = key
			button.custom_minimum_size = Vector2(42, 58)

			button.add_theme_font_size_override("font_size", 24)

			if key == "ENTER":
				button.custom_minimum_size.x = 90

			if key == "⌫":
				button.custom_minimum_size.x = 55

			button.pressed.connect(func():
				_on_keyboard_pressed(key)
			)

			row_container.add_child(button)
			keyboard_buttons[key] = button

func _on_keyboard_pressed(key: String) -> void:
	if key == "ENTER":
		enter_pressed.emit()
	elif key == "⌫":
		backspace_pressed.emit()
	else:
		letter_pressed.emit(key)
		
