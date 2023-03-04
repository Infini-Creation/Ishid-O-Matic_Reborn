extends Node

@export var debug_enabled : bool

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

var highscore_file = "user://highscores.dat"
var settings_file = "user://settings.dat"

func debug(msg : String) -> void:
	if (debug_enabled == true):
		print(msg)
