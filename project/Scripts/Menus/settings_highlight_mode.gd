extends Control

@onready var VolumeValue = $"HBoxContainer/Highlight Mode Value"

var highlight_mode : int

var highlight_text_mode : Dictionary = {
	Global.HIGHLIGHT_MODE.HIGHLIGHT_NONE: "SETTINGSHLNONE",
	Global.HIGHLIGHT_MODE.FIRST_AVAIL_MOVE: "SETTINGSHLFIRST",
	Global.HIGHLIGHT_MODE.ALL_AVAIL_MOVE: "SETTINGSHLALL",
	Global.HIGHLIGHT_MODE.RANDOM_MOVE: "SETTINGSHLRANDOM",
	Global.HIGHLIGHT_MODE.HIGHER_SCORE_MOVE: "SETTINGSHLBEST"
	}

signal settings_updated(highlight_mode)

func _ready():
	$HBoxContainer/HSlider.value = highlight_mode
	
	VolumeValue.text = "%10s" % highlight_text_mode[highlight_mode]


func load_settings(updated_highlight_mode : int) -> void:
	if updated_highlight_mode >= Global.HIGHLIGHT_MODE.HIGHLIGHT_NONE and updated_highlight_mode <= Global.HIGHLIGHT_MODE.RANDOM_MOVE:
		highlight_mode = updated_highlight_mode
	#Global.debug("umv"+str(audio_type)+"="+str(updated_audio_volume)+" ume="+str(updated_audio_enabled))
	#Global.debug("mv"+str(audio_type)+"="+str(audio_volume)+" me="+str(audio_enabled))
	
	$HBoxContainer/HSlider.value = highlight_mode
		##"%10s" % highlight_text_mode[highlight_mode]

func _on_h_slider_value_changed(value : int):
	Global.debug(highlight_text_mode[0])
	Global.debug(highlight_text_mode[value])
	VolumeValue.text = "%10s" % highlight_text_mode[value]
	settings_updated.emit(value)
