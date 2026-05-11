extends Node

const SAVE_PATH = "user://scores.json"
const TEMP_PATH = "user://scores.tmp"
const BACKUP_PATH = "user://scores.bak"

var _data: Dictionary = {}

func get_default_scores() -> Dictionary:
	return {
		"2048":{"high_score": 0,"games_played": 0},
		"snake":{"high_score": 0,"games_played": 0},
		"yahtzee":{"high_score": 0,"games_played": 0},
		"wordle":{"best_streak": 0,"games_played": 0},
		"word_bomb":{"high_score": 0,"games_played": 0},
	}

func _ready() -> void:
	_data = _load()
	print("data is loaded")
	
func get_game(game: String) -> Dictionary:
	return _data.get(game, get_default_scores().get(game, {}))

func update_game(game: String, scores: Dictionary) -> void:
	_data[game] = scores

func _load() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return get_default_scores()
	var file = FileAccess.open(SAVE_PATH,FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		push_warning("SaveManager: Save file is corrupted. Returning to previous save")
		return _load_backup()
	return parsed

func _load_backup() -> Dictionary:
	if not FileAccess.file_exists(BACKUP_PATH):
		push_warning("SaveManager: no backup found, resetting to defaults.")
		return get_default_scores()

	var file = FileAccess.open(BACKUP_PATH, FileAccess.READ)
	if file == null:
		return get_default_scores()

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()

	return parsed if parsed != null else get_default_scores()

func _save() -> void:
	var file = FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: could not open temp file. Error: %s" % FileAccess.get_open_error())
		emit_signal("save_failed")
		return
	file.store_string(JSON.stringify(_data, "\t"))
	file.close()
	
	#Verify Save
	var verify = FileAccess.open(TEMP_PATH, FileAccess.READ)
	if verify == null or JSON.parse_string(verify.get_as_text()) == null:
		push_error("SaveManager: temp file is invalid, aborting save.")
		verify.close()
		return
	verify.close()
	
	# Backup last good save
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(
			ProjectSettings.globalize_path(SAVE_PATH),
			ProjectSettings.globalize_path(BACKUP_PATH)
		)
	
	# Rewrite the current save file with the temp file to update. 
	DirAccess.rename_absolute(
		ProjectSettings.globalize_path(TEMP_PATH),
		ProjectSettings.globalize_path(SAVE_PATH)
	)
	
func record_yahtzee_result(player_won: bool) -> void:
	var data = get_game("yahtzee")
	update_game("yahtzee", {
		 # high_score = wins
		"high_score": data["high_score"] + (1 if player_won else 0),
		"games_played": data["games_played"] + 1
	})
	_save()
	
