extends Control

signal about_requested

func _on_button_pressed():
	about_requested.emit()
