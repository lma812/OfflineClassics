extends Node

signal letter_pressed(letter: String)
signal backspace_pressed
signal enter_pressed

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
