extends Control

signal quit_requested

func _on_button_pressed():
	quit_requested.emit()
