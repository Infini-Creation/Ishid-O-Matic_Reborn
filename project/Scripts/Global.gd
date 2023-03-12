extends Node

@export var debug_enabled : bool

const SETTINGS_FILE_PATH = "user://settings.ini"
const HIGHSCORES_FILE_PATH = "user://highscores.dat"

const HIGHSCORES_SCORE_START = 100
const HIGHSCORES_SCORE_STEP = 10
const HIGHSCORES_FOURWAYS_STEP = 3
const HIGHSCORES_TILES_REMAINING_STEP = 4

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
		"soundVolume": 10,
		"music": true,
		"musicVolume": 5,
		"musicToPlay": 0
	},
	"Display": {
		"screenOrientation": 0,
		"screenResolution": "TODO",
		"fullScreen": false
	},
	"hints": 0,
	"language": "TODO"
}

var highScores : Dictionary = {
	"OnePlayer" : [],
	"TwoPlayers" : [],
	"Tournament": []
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

var avail_tile_shapes = [
	preload("res://Scenes/tileA.tscn"),
	preload("res://Scenes/tileB.tscn"),
	preload("res://Scenes/tileC.tscn"),
	preload("res://Scenes/tileD.tscn"),
	preload("res://Scenes/tileE.tscn"),
	preload("res://Scenes/tileF.tscn")
]

var avail_tile_colors = {
	"color1" : Color(221,0,221,1),
	"color2" : Color(0,204,204,1),
	"color3" : Color(221,0,0,1),
	"color4" : Color(17,85,255,1),
	"color5" : Color(0,170,0,1),
	"color6" : Color(238,170,0,1)
}

enum ButtonIDs { BUTTON_1PGAME, BUTTON_2PGAME, BUTTON_TOURNAMENT, BUTTON_HELP, BUTTON_ABOUT, BUTTON_QUIT, BUTTON_SETTINGS, BUTTON_HIGHSCORES }

var tile_colors : int = 6
var tile_shapes : int = 6


func save_config():
	var config = ConfigFile.new()
	
	for item in settings:
		Global.debug("item=["+item+"]")
		if settings[item] is Dictionary:
			for subItem in settings[item]:
				Global.debug("subItem=["+subItem+"]")
				config.set_value(item, subItem, settings[item][subItem])
		else:
			config.set_value("misc", item, settings[item])
	
	var error = config.save(SETTINGS_FILE_PATH)
	if error != OK:
		Global.debug("error=["+error+"]") #TODO: deal with eror


func load_config():
	var config = ConfigFile.new()
	var error = config.load(SETTINGS_FILE_PATH)
	if error != OK:
		Global.debug("error=["+error+"]") #TODO: deal with eror
	else:
		var cfgval
	
		for item in settings:
			Global.debug("item=["+item+"]")
			if settings[item] is Dictionary:
				for subItem in settings[item]:
					Global.debug("subItem=["+subItem+"]")
					if config.has_section(item):
						if config.has_section_key(item, subItem):
							cfgval = config.get_value(item, subItem, settings[item][subItem])
							Global.debug("cfgloaded ("+item+"/"+subItem+")=["+str(cfgval)+"]")
			else:
				cfgval = config.get_value("misc", item, settings[item])
				Global.debug("cfgloaded ("+item+")=["+str(cfgval)+"]")


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

			#add names !!
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
	var highscores = ConfigFile.new()
	var error = highscores.load(HIGHSCORES_FILE_PATH)
	if error != OK:
		Global.debug("load_high_scores: error=["+str(error)+"]") #TODO: deal with eror
	else:
		pass


func save_high_scores():
	var highscores = ConfigFile.new()
	var saved_value : String
	
	#TODO: save data
	# data struct ?
	# section=1P,2P, tour
	#	key rank1=v1,v2,v3
	#	...
	for gameType in highScores:
		for idx in range(0, 10):
			#highScores[gameType][idx] = [score, fourways, tilesRemaining]
			
			saved_value = str(highScores[gameType][idx][0])+","+str(highScores[gameType][idx][1])+","+str(highScores[gameType][idx][2])
			highscores.set_value(gameType, "rank-"+str(idx), saved_value)
			
	var error = highscores.save(HIGHSCORES_FILE_PATH)
	if error != OK:
		Global.debug("error=["+error+"]") #TODO: deal with eror


func debug(msg : String) -> void:
	if (debug_enabled == true):
		print(msg)
