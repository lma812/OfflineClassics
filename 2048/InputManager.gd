extends Node

signal on_move(direction: Vector2)

var touch_start := Vector2.ZERO

@onready var game_state_manager = $"../GameStateManager"

func _input(event: InputEvent) -> void:
	# =========================
	# KEYBOARD INPUT
	# =========================
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_UP:    on_move.emit(Vector2.UP)
			KEY_DOWN:  on_move.emit(Vector2.DOWN)
			KEY_LEFT:  on_move.emit(Vector2.LEFT)
			KEY_RIGHT: on_move.emit(Vector2.RIGHT)

			# Debug keys
			KEY_W: game_state_manager.show_win()
			KEY_L: game_state_manager.show_lose()

	# =========================
	# TOUCH INPUT (SWIPE)
	# =========================
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
		else:
			var swipe: Vector2 = event.position - touch_start

			if swipe.length() > 50:
				if abs(swipe.x) > abs(swipe.y):
					on_move.emit(Vector2.RIGHT if swipe.x > 0 else Vector2.LEFT)
				else:
					on_move.emit(Vector2.DOWN if swipe.y > 0 else Vector2.UP)
