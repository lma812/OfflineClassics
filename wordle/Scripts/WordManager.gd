extends Node

var answer_words: Array[String] = []
var allowed_words: Dictionary = {}

var current_word := ""

func _ready() -> void:
	load_words()
	choose_word()

func load_words() -> void:
	var answer_file = FileAccess.open("res://wordle/words/answers.txt", FileAccess.READ)

	while not answer_file.eof_reached():
		var word = answer_file.get_line().strip_edges().to_upper()

		if word.length() == 5:
			answer_words.append(word)
			allowed_words[word] = true

	answer_file.close()

	var allowed_file = FileAccess.open("res://wordle/words/allowed.txt", FileAccess.READ)

	while not allowed_file.eof_reached():
		var word = allowed_file.get_line().strip_edges().to_upper()

		if word.length() == 5:
			allowed_words[word] = true

	allowed_file.close()

func choose_word() -> void:
	current_word = answer_words.pick_random()
	print(current_word)

func is_valid_word(word: String) -> bool:
	return allowed_words.has(word.to_upper())
