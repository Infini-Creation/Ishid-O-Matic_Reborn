extends Control

@export var playerIdx : int = 1
@export var playerLabel : String

func _ready():
	$"Background/VBoxContainer/Player Label".text = playerLabel
	$"Background/VBoxContainer/HBoxContainer/Player Score".text = "----"
	$"Background/VBoxContainer/HBoxContainer/FourWays Counter".text = "--"

#add new added points or just don't manage score here, print any value given
func update_player_score(points: int) -> void:
	#score += points
	$"Background/VBoxContainer/HBoxContainer/Player Score".text = "%4d" % points #score

func update_player_fways_counter(points: int) -> void:
	#count += points
	$"Background/VBoxContainer/HBoxContainer/FourWays Counter".text = "%2d" % points #count
