extends Control

# use global to adjust volume and/or enable/disable music

@export var audio_type : int
@export var audio_enabled_icon : Texture
@export var audio_disabled_icon : Texture

@onready var VolumeValue = $"HBoxContainer/Volume Value"

var audio_volume : int
var audio_enabled : bool

signal settings_updated(audio_type, audio_volume, audio_enabled)

func _ready():
	$HBoxContainer/TextureButton.texture_normal = audio_enabled_icon
	$HBoxContainer/TextureButton.texture_pressed = audio_disabled_icon
	
	$HBoxContainer/HSlider.value = audio_volume
	$HBoxContainer/TextureButton.button_pressed = !audio_enabled
	
	VolumeValue.text = str($HBoxContainer/HSlider.value)


func load_settings(updated_audio_volume : int, updated_audio_enabled : bool) -> void:
	if updated_audio_volume >= 0 and updated_audio_volume <= 100:
		audio_volume = updated_audio_volume
	audio_enabled = updated_audio_enabled
	Global.debug("umv"+str(audio_type)+"="+str(updated_audio_volume)+" ume="+str(updated_audio_enabled))
	Global.debug("mv"+str(audio_type)+"="+str(audio_volume)+" me="+str(audio_enabled))
	
	$HBoxContainer/HSlider.value = audio_volume
	$HBoxContainer/TextureButton.button_pressed = !audio_enabled


func _on_texture_button_toggled(button_pressed):
	Global.debug("av butt press="+str(button_pressed))
	$HBoxContainer/HSlider.editable = !button_pressed
	audio_enabled = !button_pressed
	#bp=true = audio disabled, false = enabled
	Global.debug("av settings signal="+str(button_pressed))
	settings_updated.emit(audio_type, audio_volume, !button_pressed)

func _on_h_slider_value_changed(value):
	VolumeValue.text = str(value)
	settings_updated.emit(audio_type, value, audio_enabled)
