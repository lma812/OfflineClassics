extends Node

var save_data = {
	"yahtzee": {
		"high_score": 0
	}
}

const SAVE_PATH = "user://global_save.dat"

func _ready() -> void:
	load_data()

func record_yahtzee_result(won: bool) -> void:
	if won:
		save_data["yahtzee"]["high_score"] += 1

	save_data_to_file()

func get_game(game_name: String) -> Dictionary:
	if save_data.has(game_name):
		return save_data[game_name]

	return {}

func save_data_to_file() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		return

	file.store_var(save_data)
	file.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	save_data = file.get_var()
	file.close()
