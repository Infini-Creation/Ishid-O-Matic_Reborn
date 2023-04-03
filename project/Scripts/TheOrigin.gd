extends Node

# base scene where all takes place
# init settings, HS

@onready var musicPlayer = $MusicPlayer
@onready var soundEffectPlayer = $SoundEffectPlayer

@export var currentMusic : int = 0

var mainMenuScene = preload("res://Scenes/main_menu_improved.tscn")

func _ready():
	Global.debug_enabled = true #tmp
	Global.load_config()
	Global.debug("settings="+str(Global.settings))
	
	musicPlayer.stream = Global.available_musics[currentMusic]
	
	print("setting="+str( Global.settings["Audio"]["music"] ))
	# don't forget: when music enabled => play it !
	if Global.settings["Audio"]["music"] == true:
		musicPlayer.play()

	var menu = mainMenuScene.instantiate()
	add_child(menu)
