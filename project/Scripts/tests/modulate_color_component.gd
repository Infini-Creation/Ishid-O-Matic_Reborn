extends Control

signal update_color

@export var Component : String
var colorValue : int

func _ready():
	$"HBoxContainer/Color Component".text = Component

func _on_h_slider_value_changed(value):
	colorValue = value
	update_color.emit()
