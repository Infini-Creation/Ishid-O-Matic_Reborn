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
var current_game_type : String = ""

func _ready():
	Global.debug_enabled = true #true #tmp
	Global.load_config()
	Global.debug("settings="+str(Global.settings))
	
#	Global.debug_enabled = true
#	print("init HS")
#	Global.initialize_high_scores()
#	print("save HS")
#	Global.save_high_scores()
#	print("load HS")
#	Global.load_high_scores()
	
#	print("quit")
#	get_tree().quit()
	
	if FileAccess.file_exists(Global.HIGHSCORES_FILE_PATH):
		Global.debug("load HS file")
		Global.load_high_scores()
	else:
		Global.debug("init HS file")
		Global.initialize_high_scores()
		Global.save_high_scores()

	currentMusic = randi_range(0, Global.available_musics.size()-1)
	musicPlayer.stream = Global.available_musics[currentMusic]
	
	Global.debug("setting="+str( Global.settings["Audio"]["music"] ))

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


# not connected for now ?
func _on_audio_settings_updated(new_music_volume : int, new_sound_volume: int) -> void:
	musicPlayer.volume_db = linear_to_db(new_music_volume / 100.0)
	soundEffectPlayer.volume_db = linear_to_db(new_sound_volume / 100.0)


func _on_game_launched(gameType : String):
	Global.debug("launch game="+gameType)
	current_game_type = gameType
	Global.previous_scene = get_tree().current_scene.scene_file_path
	Global.debug("prev scene=" + Global.previous_scene)

	game.setup(0, gameType)

	remove_child(menu)
	add_child(game)

	game.connect("game_end", _on_game_is_over) #may not work ??

	if Global.settings["Audio"]["soundEffects"] == true:
		game.connect("playsound", _on_game_play_soundeffect)
		#game.connect("tile_put_on_the_board", _on_game_play_tile_soundeffect)
		#game.connect("fourways", _on_game_fourways_soundeffect)
		
	#add gametype, as param,  global or to game
	#	current_session_data


func _on_game_play_soundeffect(effect : String):
	Global.debug("_on_game_play_soundeffect called with effect: "+effect)
	
	if Global.settings["Audio"]["soundEffects"] == true:
		if Global.sound_effects.has(effect):
			soundEffectPlayer.stream = Global.sound_effects[effect]
			soundEffectPlayer.play()
		else:
			Global.debug("unkown sound effect: "+effect)


# instead of a function that play game win/over sound
# better to add a func that play sound with effect as param
# (gameover, gamewon, tileplaced, 4ways, ...)
# event in game => signal(param) to here
func _on_game_is_over(status : int, playerIdx : int, score : Array, fourWays : Array, tilesRemaining : int):
	var update_hs : bool = false
	Global.debug("_on_game_is_over called, status =" + str(status))
	if status == Global.GAME_EXIT_STATUS.GAME_WON:
		Global.debug("origin/_ogio: Game won")
		update_hs = true

	elif status == Global.GAME_EXIT_STATUS.GAME_LOSS:
		Global.debug("origin/_ogio: Game loss")
		update_hs = true

	elif status == Global.GAME_EXIT_STATUS.USER_QUIT:
		Global.debug("origin/_ogio: quit")
		#return to main menu instead, display an intermediate panel first to confirm
		##get_tree().quit()
	
	# that should be done only after GOP button clicked (as well as add menu below)
	Global.debug("game child will be removed")
	remove_child(game)
	
	if update_hs == true:
		Global.debug("update HS")
		#game needs to pass values to here
		update_highscores(current_game_type, playerIdx, score, fourWays, tilesRemaining)
		
	current_game_type = ""
	add_child(menu)
	get_tree().change_scene_to_file(Global.previous_scene)


func update_highscores(gameType : String, playerIdx: int, score: Array, fourWays: Array, tilesRemainning: int) -> void:
	#need to convert player idx in string for access settings/or change settings
	Global.debug("saveHS type="+gameType+" s="+str(score)+" 4w="+str(fourWays)+" tr="+str(tilesRemainning))
	# later : play highscore update animation
		#tween ?
		# put below row one row down
		# add new row
		# wait for user to click to go back to main menu
	if gameType == Global.GAMETYPE_ONEPLAYER:
		Global.add_high_score(gameType, Global.settings["Players"]["One"], score[playerIdx], fourWays[playerIdx], tilesRemainning)
	elif gameType == Global.GAMETYPE_TWOPLAYERS:
		Global.add_high_score(gameType, Global.settings["Players"]["One"], score[0], fourWays[0], tilesRemainning)
		Global.add_high_score(gameType, Global.settings["Players"]["Two"], score[1], fourWays[1], tilesRemainning)
	elif gameType == Global.GAMETYPE_TOURNAMENT:
		pass #TODO
	elif gameType == Global.GAMETYPE_ENHANCED:
		pass #TODO

	Global.save_high_scores()
