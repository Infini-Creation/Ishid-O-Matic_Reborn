extends Control

signal button_clicked(buttonID : int)
var music_volume : int
var sound_volume : int
var music_enabled : bool
var sound_enabled : bool
var player1_name : String
var player2_name : String

func _ready():
	Global.debug_enabled = true #tmp

	#TODO in main code NOT here
	Global.load_config()
	Global.debug("settings="+str(Global.settings))
	music_enabled = Global.settings["Audio"]["music"]
	music_volume = Global.settings["Audio"]["musicVolume"]
	sound_enabled = Global.settings["Audio"]["soundEffects"]
	sound_volume = Global.settings["Audio"]["soundVolume"]
	player1_name = Global.settings["Players"]["One"]
	player2_name = Global.settings["Players"]["Two"]
	
	#init settings
	Global.debug("cmv="+str(music_volume)+" cme="+str(music_enabled))
	$"ButtonsGroup/Music Row/AudioVolume".load_settings(music_volume, music_enabled)
	$"ButtonsGroup/Sound Row/AudioVolume".load_settings(sound_volume, sound_enabled)
	$"ButtonsGroup/Music Row/settings_player1_name".load_settings(player1_name)
	$"ButtonsGroup/Sound Row/settings_player2_name".load_settings(player2_name)

func _on_accept_item_settings_save_requested():
	Global.debug("save settings clicked")
	#gather settings values
	Global.debug("music settings: vol="+str(music_volume)+" on/off="+str(music_enabled))
	Global.debug("sound settings: vol="+str(sound_volume)+" on/off="+str(sound_enabled))
	Global.debug("players: p1="+player1_name+" p2="+player2_name)
	# here maybe global function to deal with dic keys
	Global.settings["Audio"]["music"] = music_enabled
	Global.settings["Audio"]["musicVolume"] = music_volume
	Global.settings["Audio"]["soundEffects"] = sound_enabled
	Global.settings["Audio"]["soundVolume"] = sound_volume
	Global.settings["Players"]["One"] = player1_name
	Global.settings["Players"]["Two"] = player2_name
	Global.save_config()
	
	button_clicked.emit(Global.ButtonIDs.BUTTON_SETTINGS_SAVE)

func _on_back_item_settings_revert_requested():
	Global.debug("back clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_SETTINGS_BACK)

#??
func _on_quit_item_quit_requested():
	pass # Replace with function body.

func _on_music_volume_settings_updated(new_music_volume, new_music_enabled):
	Global.debug("music settings: vol="+str(new_music_volume)+" on/off="+str(new_music_enabled))
	music_volume = new_music_volume
	music_enabled = new_music_enabled

func _on_sound_volume_settings_updated(new_sound_volume, new_sound_enabled):
	#Global.debug("sound settings: vol="+str(new_sound_volume)+" on/off="+str(new_sound_enabled))
	sound_volume = new_sound_volume
	sound_enabled = new_sound_enabled

func _on_settings_player_1_name_settings_updated(new_player_name):
	Global.debug("new p1 name="+new_player_name)
	player1_name = new_player_name

func _on_settings_player_2_name_settings_updated(new_player_name):
	Global.debug("new p2 name="+new_player_name)
	player2_name = new_player_name


func _on_settings_player_1_name_gui_input(_event):
	$"ButtonsGroup/Music Row/DummySpacerOne".hide()
	$"ButtonsGroup/Music Row/PlayerHint".show()

func _on_settings_player_1_name_mouse_exited():
	$"ButtonsGroup/Music Row/PlayerHint".hide()
	$"ButtonsGroup/Music Row/DummySpacerOne".show()

func _on_settings_player_2_name_gui_input(_event):
	$"ButtonsGroup/Sound Row/DummySpacerTwo".hide()
	$"ButtonsGroup/Sound Row/PlayerHint2".show()

func _on_settings_player_2_name_mouse_exited():
	$"ButtonsGroup/Sound Row/PlayerHint2".hide()
	$"ButtonsGroup/Sound Row/DummySpacerTwo".show()


func _on_audio_volume_settings_updated(audio_type, new_audio_volume, new_audio_enabled):
	Global.debug("audio settings("+str(audio_type)+"): vol="+str(new_audio_volume)+" on/off="+str(new_audio_enabled))
	if audio_type == Global.AUDIO_TYPE_MUSIC:
		music_volume = new_audio_volume
		music_enabled = new_audio_enabled
	else:
		sound_volume = new_audio_volume
		sound_enabled = new_audio_enabled
