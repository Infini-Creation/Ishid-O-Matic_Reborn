extends Node

@export var debug_enabled : bool

const SETTINGS_FILE_PATH = "user://settings.ini"
const HIGHSCORES_FILE_PATH = "user://highscores.dat"
const SEED_FILE_PATH = "user://tournament.seed"

const HIGHSCORES_SCORE_START = 100
const HIGHSCORES_SCORE_STEP = 10
const HIGHSCORES_FOURWAYS_STEP = 3
const HIGHSCORES_TILES_REMAINING_STEP = 4

const GAMETYPE_ONEPLAYER : String = "OnePlayer"
const GAMETYPE_TWOPLAYERS : String = "TwoPlayers"
const GAMETYPE_TOURNAMENT : String = "Tournament"
const GAMETYPE_ENHANCED : String = "Enhanced"

const HIGHSCORES_NAME_IDX = 0
const HIGHSCORES_SCORE_IDX = 1
const HIGHSCORES_FOURWAYS_IDX = 2
const HIGHSCORES_TILESREMAINING_IDX = 3

const AUDIO_TYPE_SOUNDEFFECT = 0
const AUDIO_TYPE_MUSIC = 1

var stats : Dictionary = {
	"GamesPlayed": 0,
	"GamesWon": 0,
	"GamesLost": 0,
	"TotalScore": 0,
	"TotalTilesPlaced": 0,
	"TotalFourWays": 0,
	"TotalThreeWays": 0,
	"TotalTwoWays": 0
}

var settings : Dictionary = {
	"Audio": { 
		"soundEffects": true,
		"soundVolume": 100,
		"music": true,
		"musicVolume": 75,
		"musicToPlay": 0
	},
	"Display": {
		"screenOrientation": 0,
		"screenResolution": "TODO",
		"fullScreen": false
	},
	"Players": {
		"One": "Player1",
		"Two": "Player2"
	},
	"hints": 0,
	"language": 0,
	"tileSet": "default"
}

var highScores : Dictionary = {
	"OnePlayer" : [],
	"TwoPlayers" : [],
	"Tournament": [],
	"Enhanced": []
}

var dummyNames : Array = [
	"Robert Brandner",
	"Brad Fregger",
	"Michael Feinberg",
	"Ian Gilman",
	"Mike Sandige",
	"John Sullivan",
	"Sean Cummins",
	"Steven Samorodin"
]

const avail_tile_shapes = {
	"A": preload("res://Scenes/tileA.tscn"),
	"B": preload("res://Scenes/tileB.tscn"),
	"C": preload("res://Scenes/tileC.tscn"),
	"D": preload("res://Scenes/tileD.tscn"),
	"E": preload("res://Scenes/tileE.tscn"),
	"F": preload("res://Scenes/tileF.tscn")
}

const avail_tile_colors = {
	"color1" : Color(221,0,221,1),
	"color2" : Color(0,204,204,1),
	"color3" : Color(221,0,0,1),
	"color4" : Color(17,85,255,1),
	"color5" : Color(0,170,0,1),
	"color6" : Color(238,170,0,1)
}

# hold tile ref with tileset as placeholder
# use a standard tile scene to instantiate scene on deckdisplay scene only 

# does stoneset var really useful: DLC: replace stone and other gfx as a whole
# put data in their own scene
# even doesn't store them, reload each time they're changed
const Stones : Dictionary = {
		"A1": preload("res://Arts/Gfx/Tiles/default/A1.png"),
		"A2": preload("res://Arts/Gfx/Tiles/default/A2.png"),
		"A3": preload("res://Arts/Gfx/Tiles/default/A3.png"),
		"A4": preload("res://Arts/Gfx/Tiles/default/A4.png"),
		"A5": preload("res://Arts/Gfx/Tiles/default/A5.png"),
		"A6": preload("res://Arts/Gfx/Tiles/default/A6.png"),
		"B1": preload("res://Arts/Gfx/Tiles/default/B1.png"),
		"B2": preload("res://Arts/Gfx/Tiles/default/B2.png"),
		"B3": preload("res://Arts/Gfx/Tiles/default/B3.png"),
		"B4": preload("res://Arts/Gfx/Tiles/default/B4.png"),
		"B5": preload("res://Arts/Gfx/Tiles/default/B5.png"),
		"B6": preload("res://Arts/Gfx/Tiles/default/B6.png"),
		"C1": preload("res://Arts/Gfx/Tiles/default/C1.png"),
		"C2": preload("res://Arts/Gfx/Tiles/default/C2.png"),
		"C3": preload("res://Arts/Gfx/Tiles/default/C3.png"),
		"C4": preload("res://Arts/Gfx/Tiles/default/C4.png"),
		"C5": preload("res://Arts/Gfx/Tiles/default/C5.png"),
		"C6": preload("res://Arts/Gfx/Tiles/default/C6.png"),
		"D1": preload("res://Arts/Gfx/Tiles/default/D1.png"),
		"D2": preload("res://Arts/Gfx/Tiles/default/D2.png"),
		"D3": preload("res://Arts/Gfx/Tiles/default/D3.png"),
		"D4": preload("res://Arts/Gfx/Tiles/default/D4.png"),
		"D5": preload("res://Arts/Gfx/Tiles/default/D5.png"),
		"D6": preload("res://Arts/Gfx/Tiles/default/D6.png"),
		"E1": preload("res://Arts/Gfx/Tiles/default/E1.png"),
		"E2": preload("res://Arts/Gfx/Tiles/default/E2.png"),
		"E3": preload("res://Arts/Gfx/Tiles/default/E3.png"),
		"E4": preload("res://Arts/Gfx/Tiles/default/E4.png"),
		"E5": preload("res://Arts/Gfx/Tiles/default/E5.png"),
		"E6": preload("res://Arts/Gfx/Tiles/default/E6.png"),
		"F1": preload("res://Arts/Gfx/Tiles/default/F1.png"),
		"F2": preload("res://Arts/Gfx/Tiles/default/F2.png"),
		"F3": preload("res://Arts/Gfx/Tiles/default/F3.png"),
		"F4": preload("res://Arts/Gfx/Tiles/default/F4.png"),
		"F5": preload("res://Arts/Gfx/Tiles/default/F5.png"),
		"F6": preload("res://Arts/Gfx/Tiles/default/F6.png")
}

# maybe play one music per day of week ?
const available_musics = [
	preload("res://audio/musics/Alone-Again_Looping.mp3"),
	preload("res://audio/musics/Deep-Peace_Looping.mp3"),
	preload("res://audio/musics/Distant-Mountains_Looping.mp3"),
	preload("res://audio/musics/Hidden-Pond_Looping.mp3"),
	preload("res://audio/musics/Icicles_Looping.mp3"),
	preload("res://audio/musics/Valley-Sunrise_Looping.mp3")
]

const sound_effects = {
	"tile": preload("res://audio/effects/Footstep_Tile_Left.mp3"),
	"fourways": preload("res://audio/effects/SynthChime11.mp3"),
	"loss": preload("res://audio/effects/DroneAlert3.mp3"),
	"lossA": preload("res://audio/effects/DroneAlert4.mp3"),
	"lossB": preload("res://audio/effects/DroneAlert5.mp3"),
	#"win": preload("res://audio/effects/")
}

enum ButtonIDs { BUTTON_1PGAME, BUTTON_2PGAME, BUTTON_TOURNAMENT, BUTTON_ENHANCED, BUTTON_HELP, BUTTON_ABOUT, BUTTON_QUIT, BUTTON_SETTINGS, BUTTON_HIGHSCORES, BUTTON_SETTINGS_BACK, BUTTON_SETTINGS_SAVE }
enum HIGHLIGHT_MODE { HIGHLIGHT_NONE, FIRST_AVAIL_MOVE, ALL_AVAIL_MOVE, RANDOM_MOVE, HIGHER_SCORE_MOVE }
enum LANGUAGE { ENGLISH, FRENCH, OTHER }
enum GAME_EXIT_STATUS { GAME_WON, GAME_LOSS, USER_QUIT }

var tile_colors : int = 6
var tile_shapes : int = 6

var previous_scene : String
var configLoaded : bool = false
var continue_tournament : bool = true
var tournamentSeed : int

func save_config() -> bool:
	var config = ConfigFile.new()
	var ok : bool = true

	for item in settings:
		Global.debug("sav item=["+item+"]")
		if settings[item] is Dictionary:
			for subItem in settings[item]:
				Global.debug("sav subItem=["+subItem+"]="+str(settings[item][subItem]))
				config.set_value(item, subItem, settings[item][subItem])
		else:
			Global.debug("misc val=["+str(settings[item])+"]")
			config.set_value("misc", item, settings[item])
	
	var error = config.save(SETTINGS_FILE_PATH)
	if error != OK:
		Global.debug("sav error=["+error+"]") #TODO: deal with eror
			#or log to file
		ok = false

	return ok


func load_config():
	if configLoaded == true:
		Global.debug("cfg already loaded, skip")
		return

	var config = ConfigFile.new()
	var error = config.load(SETTINGS_FILE_PATH)
	if error != OK:
		Global.debug("load error=["+str(error)+"]") #TODO: deal with eror
	else:
	
		for item in settings:
			Global.debug("item=["+item+"]")
			if settings[item] is Dictionary:
				for subItem in settings[item]:
					Global.debug("subItem=["+subItem+"]")
					if config.has_section(item):
						if config.has_section_key(item, subItem):
							settings[item][subItem] = config.get_value(item, subItem, settings[item][subItem])
							Global.debug("cfgloaded ("+item+"/"+subItem+")=["+str(settings[item][subItem])+"]")
			else:
				settings[item] = config.get_value("misc", item, settings[item])
				Global.debug("cfgloaded ("+item+")=["+str(settings[item])+"]")
	Global.debug("LoadConf: settings="+str(settings))
	configLoaded = true


func initialize_high_scores():
	var score : int
	var fourways : int
	var tilesRemaining : int
	var random_name : String

	for gameType in highScores:
		highScores[gameType] = []
		highScores[gameType].resize(10)
		
		score = HIGHSCORES_SCORE_START
		fourways = HIGHSCORES_FOURWAYS_STEP
		tilesRemaining = 0

		for idx in range(0, 10):
			if (gameType != "Tournament"):
				random_name = dummyNames[randi_range(0,dummyNames.size() - 1)]
			else:
				random_name = ""
			
			highScores[gameType][idx] = [random_name, score, fourways, tilesRemaining]
			#debug("init array idx="+str(idx))
			score -= HIGHSCORES_SCORE_STEP
			if (idx + 1) % HIGHSCORES_FOURWAYS_STEP == 0:
				fourways -= 1
			tilesRemaining += HIGHSCORES_TILES_REMAINING_STEP


func load_high_scores():
	if highScores[GAMETYPE_ONEPLAYER].size() == 0:
		var highscores = FileAccess.open(HIGHSCORES_FILE_PATH, FileAccess.READ)
		var error = FileAccess.get_open_error()
		if error == ERR_FILE_NOT_FOUND:
			Global.debug("HS file does not exists, initialize HS")
			initialize_high_scores()
			save_high_scores()
		elif error != OK:
			Global.debug("load_high_scores: error=["+str(error)+"]") #TODO: deal with eror
			#deal with filenotfound => init hs
		else:
			var gameType : String

			for gtidx in range(0, highScores.size()):
				gameType = highscores.get_pascal_string()
				highScores[gameType] = []
				highScores[gameType].resize(10)
				Global.debug("lHS gt="+gameType)

				for idx in range(0, 10):
					Global.debug("gt["+gameType+"] file array idx="+str(idx))
					highScores[gameType][idx] = []
					highScores[gameType][idx].resize(4)
					Global.debug("gt["+gameType+"] array ="+str(highScores[gameType][idx]))
					
					highScores[gameType][idx][HIGHSCORES_NAME_IDX] = highscores.get_pascal_string()
					highScores[gameType][idx][HIGHSCORES_SCORE_IDX] = highscores.get_16()
					highScores[gameType][idx][HIGHSCORES_FOURWAYS_IDX] = highscores.get_8()
					highScores[gameType][idx][HIGHSCORES_TILESREMAINING_IDX] = highscores.get_8()
					Global.debug("gt["+gameType+"] loaded array ="+str(highScores[gameType][idx]))
					#highscores.get_error()
			highscores.close()


func save_high_scores():
	var highscores = FileAccess.open(HIGHSCORES_FILE_PATH, FileAccess.WRITE)
	var error = FileAccess.get_open_error()
	if error != Error.OK:
		Global.debug("save_high_scores: error=["+error+"]") #TODO: deal with eror

	for gameType in highScores:
		Global.debug("sHS gt="+gameType)
		highscores.store_pascal_string(gameType)

		for idx in range(0, 10):
			highscores.store_pascal_string(highScores[gameType][idx][HIGHSCORES_NAME_IDX])
			highscores.store_16(highScores[gameType][idx][HIGHSCORES_SCORE_IDX])
			highscores.store_8(highScores[gameType][idx][HIGHSCORES_FOURWAYS_IDX])
			highscores.store_8(highScores[gameType][idx][HIGHSCORES_TILESREMAINING_IDX])
			#highscores.get_error()
			
	highscores.close()


func add_high_score(gameType, playerName : String, score : int, fourWays : int, tilesRemaining : int)  -> void:
	for scoreIdx in range(0, highScores[gameType].size()):
		debug("score="+str(score)+" vs hs="+str(highScores[gameType][scoreIdx][HIGHSCORES_SCORE_IDX]))
		if score >= highScores[gameType][scoreIdx][HIGHSCORES_SCORE_IDX]:
			highScores[gameType].insert(scoreIdx, [playerName, score, fourWays, tilesRemaining])
			highScores[gameType].pop_back()
			break


func load_seed() -> int:
	var saved_seed : int = 0

	var seedfile = FileAccess.open(SEED_FILE_PATH, FileAccess.READ)
	var error = FileAccess.get_open_error()

	if error == ERR_FILE_NOT_FOUND:
		Global.debug("seed file does not exists")
		saved_seed = Time.get_ticks_usec()
		save_seed(saved_seed)
	elif error != OK:
		Global.debug("load_seed: error=["+str(error)+"]") #TODO: deal with eror
	else:
		saved_seed = seedfile.get_16()
		seedfile.close()

	return saved_seed


func save_seed(tournament_seed: int) -> bool:
	var save_ok : bool = false
	
	var seedfile = FileAccess.open(SEED_FILE_PATH, FileAccess.WRITE)
	var error = FileAccess.get_open_error()

	if error != Error.OK:
		Global.debug("save_seed: error=["+error+"]") #TODO: deal with eror
	else:
		seedfile.store_16(tournament_seed)
		seedfile.close()
		save_ok = true

	return save_ok


func debug(msg : String) -> void:
	if (debug_enabled == true):
		print(msg)
