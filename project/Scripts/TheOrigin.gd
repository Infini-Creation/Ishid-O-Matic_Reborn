extends Node

# base scene where all takes place
# init settings, HS

@onready var musicPlayer = $MusicPlayer
@onready var soundEffectPlayer = $SoundEffectPlayer

@export var currentMusic : int = 0

var mainMenuScene = preload("res://Scenes/main_menu_improved.tscn")
var gameScene = preload("res://Scenes/game.tscn")

var menu
var game

func _ready():
	Global.debug_enabled = true #tmp
	Global.load_config()
	Global.debug("settings="+str(Global.settings))
	
	musicPlayer.stream = Global.available_musics[currentMusic]
	
	print("setting="+str( Global.settings["Audio"]["music"] ))
	# don't forget: when music enabled => play it !
	if Global.settings["Audio"]["music"] == true:
		musicPlayer.volume_db = linear_to_db(Global.settings["Audio"]["musicVolume"] / 100.0)
		musicPlayer.play()
	
	if Global.settings["Audio"]["soundEffects"] == true:
		soundEffectPlayer.volume_db = linear_to_db(Global.settings["Audio"]["soundVolume"] / 100.0)

	menu = mainMenuScene.instantiate()
	game = gameScene.instantiate()

	add_child(menu)
	#get_tree().get_root().print_tree()
	menu.connect("launch_game", _on_game_launched)


func _on_audio_settings_updated(new_music_volume : int, new_sound_volume: int) -> void:
	musicPlayer.volume_db = linear_to_db(new_music_volume / 100.0)
	soundEffectPlayer.volume_db = linear_to_db(new_sound_volume / 100.0)

func _on_game_launched(gameType : String):
	Global.debug("launch game="+gameType)
	Global.previous_scene = get_tree().current_scene.scene_file_path
	Global.debug("prev scene=" + Global.previous_scene)
	remove_child(menu)
	add_child(game)
	game.connect("game_end", _on_game_is_over)
	#add gametype, as param,  global or to game
	#	current_session_data

func _on_game_is_over(status : int):
	if status == Global.GAME_EXIT_STATUS.GAME_WON:
		Global.debug("Game won")
	elif status == Global.GAME_EXIT_STATUS.GAME_LOSS:
		Global.debug("Game loss")
	elif status == Global.GAME_EXIT_STATUS.USER_QUIT:
		Global.debug("quit")
