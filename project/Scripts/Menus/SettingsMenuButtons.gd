extends Control

signal button_clicked(buttonID : int)
var music_volume : int
var sound_volume : int
var music_enabled : bool
var sound_enabled : bool

func _ready():
	Global.debug_enabled = true #tmp
	#load/init settings

func _on_accept_item_settings_save_requested():
	Global.debug("save settings clicked")
	#gather settings values
	Global.debug("music settings: vol="+str(music_volume)+" on/off="+str(music_enabled))
	Global.debug("sound settings: vol="+str(sound_volume)+" on/off="+str(sound_enabled))
	
	button_clicked.emit(Global.ButtonIDs.BUTTON_SETTINGS_SAVE)

func _on_back_item_settings_revert_requested():
	Global.debug("back clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_SETTINGS_BACK)


func _on_quit_item_quit_requested():
	pass # Replace with function body.

func _on_music_volume_settings_updated(new_music_volume, new_music_enabled):
	#Global.debug("music settings: vol="+str(new_music_volume)+" on/off="+str(new_music_enabled))
	music_volume = new_music_volume
	music_enabled = new_music_enabled

func _on_sound_volume_settings_updated(new_sound_volume, new_sound_enabled):
	#Global.debug("sound settings: vol="+str(new_sound_volume)+" on/off="+str(new_sound_enabled))
	sound_volume = new_sound_volume
	sound_enabled = new_sound_enabled
