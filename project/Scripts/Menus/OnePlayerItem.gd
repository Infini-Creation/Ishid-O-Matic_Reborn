extends Control

signal oneplayer_game_requested

func _on_button_pressed():
	oneplayer_game_requested.emit()
