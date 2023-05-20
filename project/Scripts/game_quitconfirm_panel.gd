extends Control

signal quit(confirm : bool)

func _on_yes_button_pressed():
	quit.emit(true)

func _on_no_button_pressed():
	quit.emit(false)
