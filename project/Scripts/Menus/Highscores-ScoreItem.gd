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
	
	var rankstr : String = ""
	if newRank < 10:
		rankstr = " "

	#need fixed size font
	$PanelContainer/HBoxContainer/Rank.text = rankstr + str(newRank) + "."
	$PanelContainer/HBoxContainer/Name.text = newName
	$PanelContainer/HBoxContainer/Score.text = str(newScore)
	$PanelContainer/HBoxContainer/FourWays.text = str(newFourWaysCount)
	$PanelContainer/HBoxContainer/TilesRemaining.text = str(newRemainingTiles)

func set_values(newRank : int, newName : String, newScore : int, newFourWaysCount : int, newRemainingTiles : int) -> void:
	$PanelContainer/HBoxContainer/Rank.text = str(newRank)
	$PanelContainer/HBoxContainer/Name.text = newName
	$PanelContainer/HBoxContainer/Score.text = str(newScore)
	$PanelContainer/HBoxContainer/FourWays.text = str(newFourWaysCount)
	$PanelContainer/HBoxContainer/TilesRemaining.text = str(newRemainingTiles)
