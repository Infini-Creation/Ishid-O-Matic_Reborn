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
	
	currentMusic = randi_range(0, Global.available_musics.size()-1)
	musicPlayer.stream = Global.available_musics[currentMusic]
	
	print("setting="+str( Global.settings["Audio"]["music"] ))

	if Global.settings["Audio"]["music"] == true:
		musicPlayer.volume_db = linear_to_db(Global.settings["Audio"]["musicVolume"] / 100.0)
		musicPlayer.play()
	else:
		musicPlayer.stop()

	if Global.settings["Audio"]["soundEffects"] == true:
		soundEffectPlayer.volume_db = linear_to_db(Global.settings["Audio"]["soundVolume"] / 100.0)
	else:
		soundEffectPlayer.stop()

	menu = mainMenuScene.instantiate()
	game = gameScene.instantiate()

	add_child(menu)
	#get_tree().get_root().print_tree()
	menu.connect("launch_game", _on_game_launched)


# no connected for now ?
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
	
	if Global.settings["Audio"]["soundEffects"] == true:
		game.connect("tile_put_on_the_board", _on_game_play_tile_soundeffect)
		game.connect("fourways", _on_game_fourways_soundeffect)
	#add gametype, as param,  global or to game
	#	current_session_data


func _on_game_is_over(status : int):
	if status == Global.GAME_EXIT_STATUS.GAME_WON:
		Global.debug("Game won")
		#soundEffectPlayer.stream = Global.sound_effects["win"]
		#soundEffectPlayer.play()
	elif status == Global.GAME_EXIT_STATUS.GAME_LOSS:
		Global.debug("Game loss")
		
		if Global.settings["Audio"]["soundEffects"] == true:
			soundEffectPlayer.stream = Global.sound_effects["loss"] #A B variant = random
			soundEffectPlayer.play()
	elif status == Global.GAME_EXIT_STATUS.USER_QUIT:
		Global.debug("quit")


func _on_game_play_tile_soundeffect():
	Global.debug("_on_game_play_tile_soundeffect called")
	soundEffectPlayer.stream = Global.sound_effects["tile"]
	soundEffectPlayer.play()


func _on_game_fourways_soundeffect():
	Global.debug("_on_game_fourways_soundeffect called")
	soundEffectPlayer.stream = Global.sound_effects["fourways"]
	soundEffectPlayer.play()
