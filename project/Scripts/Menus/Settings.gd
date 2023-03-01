extends Control

signal settings_requested

func _on_button_pressed():
	settings_requested.emit()
