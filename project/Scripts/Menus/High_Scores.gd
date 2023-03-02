extends Control

signal highscores_requested

func _on_button_pressed():
	highscores_requested.emit()
