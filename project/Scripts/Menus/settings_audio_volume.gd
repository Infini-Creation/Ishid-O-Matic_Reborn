extends Control

# use global to adjust volume and/or enable/disable music

@export var audio_enabled_icon : Texture
@export var audio_disabled_icon : Texture

@onready var VolumeValue = $"HBoxContainer/Volume Value"

var audio_volume : int
var audio_enabled : bool

signal settings_updated(int, bool)

func _ready():
	Global.debug_enabled = true #tmp

	$HBoxContainer/TextureButton.texture_normal = audio_enabled_icon
	$HBoxContainer/TextureButton.texture_pressed = audio_disabled_icon
	
	$HBoxContainer/HSlider.value = audio_volume
	$HBoxContainer/TextureButton.button_pressed = !audio_enabled
	
	VolumeValue.text = str($HBoxContainer/HSlider.value)


func load_settings(updated_audio_volume : int, updated_music_enabled : bool) -> void:
	if updated_audio_volume >= 0 and updated_audio_volume <= 100:
		audio_volume = updated_audio_volume
	audio_enabled = updated_music_enabled
	Global.debug("umv="+str(updated_audio_volume)+" ume="+str(updated_music_enabled))
	Global.debug("mv="+str(audio_volume)+" me="+str(audio_enabled))
	
	$HBoxContainer/HSlider.value = audio_volume
	$HBoxContainer/TextureButton.button_pressed = !audio_enabled


func _on_texture_button_toggled(button_pressed):
	Global.debug("butt press="+str(button_pressed))
	$HBoxContainer/HSlider.editable = !button_pressed
	#bp=true = music disabled, false = enabled
	settings_updated.emit(audio_volume, !button_pressed)

func _on_h_slider_value_changed(value):
	VolumeValue.text = str(value)
	settings_updated.emit(value, audio_enabled)
