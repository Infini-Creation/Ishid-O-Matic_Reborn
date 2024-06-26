extends Control

signal button_clicked(buttonID : int)
signal sound_volume_updated(type: int, volume: int)
signal language_updated(lang: int)

var music_volume : int
var sound_volume : int
var music_enabled : bool
var sound_enabled : bool
var player1_name : String
var player2_name : String
var highlight_mode : int
var language : int


func _ready():
	#TODO in main code NOT here
	Global.load_config()
	Global.debug("settings="+str(Global.settings))

	music_enabled = Global.settings["Audio"]["music"]
	music_volume = Global.settings["Audio"]["musicVolume"]
	sound_enabled = Global.settings["Audio"]["soundEffects"]
	sound_volume = Global.settings["Audio"]["soundVolume"]
	player1_name = Global.settings["Players"]["One"]
	player2_name = Global.settings["Players"]["Two"]
	highlight_mode = Global.settings["hints"]
	language = Global.settings["language"]
	
	# set it to "test" for lg=2 (tatar)
	var displayedLangText : String = TranslationServer.get_language_name(Global.AVAILABLE_LANGUAGES[language])
	if language == 2:
		displayedLangText = "test"
	$"ButtonsGroup/Hints-Language Row/LanguageSelector".text = displayedLangText

	#init settings
	Global.debug("cmv="+str(music_volume)+" cme="+str(music_enabled))
	$"ButtonsGroup/Music Row/AudioVolume".load_settings(music_volume, music_enabled)
	$"ButtonsGroup/Sound Row/AudioVolume".load_settings(sound_volume, sound_enabled)
	$"ButtonsGroup/Music Row/settings_player1_name".load_settings(player1_name)
	$"ButtonsGroup/Sound Row/settings_player2_name".load_settings(player2_name)
	$"ButtonsGroup/Hints-Language Row/HighlightMode".load_settings(highlight_mode)
	#Global.debug("hlm="+str(highlight_mode)+" lang="+str(language))
	#init language button (selected = pressed)

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
	Global.settings["hints"] = highlight_mode
	Global.settings["language"] = language

	if Global.save_config() == true:
		$ButtonsGroup/DummySpacer2/SettingsSavedOKLabel.show()
	else:
		$ButtonsGroup/DummySpacer2/SettingsSavedKOLabel.show()
	#start timer here then hide when timeout
	$OkKoMsgTimer.start()
	
	button_clicked.emit(Global.ButtonIDs.BUTTON_SETTINGS_SAVE)

func _on_back_item_settings_revert_requested():
	Global.debug("back clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_SETTINGS_BACK)

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

func _on_highlight_mode_settings_updated(mode):
	highlight_mode = mode
	
func _on_audio_volume_settings_updated(audio_type, new_audio_volume, new_audio_enabled):
	Global.debug("audio settings("+str(audio_type)+"): vol="+str(new_audio_volume)+" on/off="+str(new_audio_enabled))
	if audio_type == Global.AUDIO_TYPE_MUSIC:
		music_volume = new_audio_volume
		music_enabled = new_audio_enabled

		if music_enabled == true:
			sound_volume_updated.emit(Global.AUDIO_TYPE_MUSIC, music_volume)
		else:
			sound_volume_updated.emit(Global.AUDIO_TYPE_MUSIC, 0)
	else:
		sound_volume = new_audio_volume
		sound_enabled = new_audio_enabled

		if sound_enabled == true:
			sound_volume_updated.emit(Global.AUDIO_TYPE_SOUNDEFFECT, sound_volume)
		else:
			sound_volume_updated.emit(Global.AUDIO_TYPE_SOUNDEFFECT, 0)

	#TODO: update volume for music + add sound effect test when updating volume of SE
	#HERE: signal back with volume value


func _on_ok_ko_msg_timer_timeout() -> void:
	$ButtonsGroup/DummySpacer2/SettingsSavedOKLabel.hide()
	$ButtonsGroup/DummySpacer2/SettingsSavedKOLabel.hide()


func _on_label_gui_input(event: InputEvent) -> void:
	var displayedLangText = TranslationServer.get_language_name(Global.AVAILABLE_LANGUAGES[Global.settings["language"]])

	#Global.debug("label InEv="+str(event))
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			language += 1
			language %= Global.AVAILABLE_LANGUAGES.size()
			#var labtext = Global.AVAILABLE_LANGUAGES[language]

			#Global.debug("text = "+labtext+"  langn="+TranslationServer.get_language_name(labtext))
			#displayedLangText = TranslationServer.get_language_name(labtext)
			displayedLangText = Global.LANGUAGE_NAME_TRANSLATION[language]
				#here : translate language name natively if possible
			language_updated.emit(language)

			##if labtext == "tt":
			##	displayedLangText = "test"

			$"ButtonsGroup/Hints-Language Row/LanguageSelector".text = displayedLangText
