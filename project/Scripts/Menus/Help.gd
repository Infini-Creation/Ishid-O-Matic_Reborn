extends Control

signal help_requested

func _ready():
	pass

func _on_button_pressed():
	help_requested.emit()
