extends Control

var Rank : int
var Name : String
var Score : int
var FourWaysCount : int
var RemainingTiles : int

func _ready():
	pass
	
func init(newRank : int, newName : String, newScore : int, newFourWaysCount : int, newRemainingTiles : int):
	Rank = newRank
	Name = newName
	Score = newScore
	FourWaysCount = newFourWaysCount
	RemainingTiles = newRemainingTiles
	
	#need fixed size font
	$PanelContainer/HBoxContainer/Rank.text = "%2d." % newRank
	$PanelContainer/HBoxContainer/Name.text = newName
	$PanelContainer/HBoxContainer/Score.text = "%3d" % newScore
	$PanelContainer/HBoxContainer/FourWays.text = "%2d" % newFourWaysCount
	$PanelContainer/HBoxContainer/TilesRemaining.text = "%2d" % newRemainingTiles

# not used, to remove
func set_values(newRank : int, newName : String, newScore : int, newFourWaysCount : int, newRemainingTiles : int) -> void:
	$PanelContainer/HBoxContainer/Rank.text = str(newRank)
	$PanelContainer/HBoxContainer/Name.text = newName
	$PanelContainer/HBoxContainer/Score.text = str(newScore) #3 char padding
	$PanelContainer/HBoxContainer/FourWays.text = str(newFourWaysCount)
	$PanelContainer/HBoxContainer/TilesRemaining.text = str(newRemainingTiles) # 2 chars pad
