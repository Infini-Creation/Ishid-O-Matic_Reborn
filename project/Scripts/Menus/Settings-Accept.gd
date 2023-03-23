extends Control

signal settings_save_requested

func _on_button_pressed():
	settings_save_requested.emit()
