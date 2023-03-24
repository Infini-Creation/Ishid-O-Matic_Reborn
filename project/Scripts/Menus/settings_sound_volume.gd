extends Control

# use global to adjust volume and/or enable/disable sound
@onready var VolumeValue = $"HBoxContainer/Volume Value"

var sound_volume : int
var sound_enabled : bool

signal settings_updated(int, bool)

func _ready():
	#init from settings, here fake sample data for testing
	#sound_volume = 12
	#sound_enabled = false
	
	$HBoxContainer/HSlider.value = sound_volume
	$HBoxContainer/TextureButton.button_pressed = !sound_enabled
	
	VolumeValue.text = str($HBoxContainer/HSlider.value)


func load_settings(updated_sound_volume : int, updated_sound_enabled : bool) -> void:
	if updated_sound_volume >= 0 and updated_sound_volume <= 100:
		sound_volume = updated_sound_volume
	sound_enabled = updated_sound_enabled
	


func _on_texture_button_toggled(button_pressed):
	print("butt press="+str(button_pressed))
	$HBoxContainer/HSlider.editable = !button_pressed
	#bp=true = sound disabled, false = enabled !!=> depend on initial state !!
	settings_updated.emit(sound_volume, !button_pressed)

func _on_h_slider_value_changed(value):
	VolumeValue.text = str(value)
	settings_updated.emit(value, sound_enabled)
