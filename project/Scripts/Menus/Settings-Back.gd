extends Control

signal settings_revert_requested

func _on_button_pressed():
	settings_revert_requested.emit()
