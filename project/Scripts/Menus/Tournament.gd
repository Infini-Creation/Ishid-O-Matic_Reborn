extends Control

signal tournament_game_requested

func _on_button_pressed():
	tournament_game_requested.emit()
