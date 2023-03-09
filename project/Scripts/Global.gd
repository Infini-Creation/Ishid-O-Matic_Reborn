extends Node

@export var debug_enabled : bool

const SETTINGS_FILE_PATH = "user://settings.ini"
const HIGHSCORES_FILE_PATH = "user://highscores.dat"

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
	for gameType in highScores:
		highScores[gameType] = []
		for idx in randi_range(0, 9):
			highScores[gameType][idx] = [0, 0, 0]
			#score from 10 to 100 by 10, rem tiles from 32 to 0 by 4
			# 4w: 1 to 3


func load_high_scores():
	var highscores = ConfigFile.new()
	var error = highscores.load(HIGHSCORES_FILE_PATH)
	if error != OK:
		Global.debug("error=["+error+"]") #TODO: deal with eror
	else:
		pass


func save_high_scores():
	var highscores = ConfigFile.new()
	
	#TODO: save data

	var error = highscores.save(HIGHSCORES_FILE_PATH)
	if error != OK:
		Global.debug("error=["+error+"]") #TODO: deal with eror


func debug(msg : String) -> void:
	if (debug_enabled == true):
		print(msg)
