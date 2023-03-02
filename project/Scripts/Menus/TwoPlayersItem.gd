extends Control

signal twoplayers_game_requested

func _on_button_pressed():
	twoplayers_game_requested.emit()
