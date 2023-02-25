extends Control

#var score : int = 0
#var count : int = 0

func _ready():
	$"Player2 Score".text = "----" #str(score)
	$"FourWays Counter".text = "--" #str(count)

#add new added points or just don't manage score here, print any value given
func update_player_score(points: int) -> void:
	#score += points
	$"Player2 Score".text = "%4d" % points #score

func update_player_fways_counter(points: int) -> void:
	#count += points
	$"FourWays Counter".text = "%2d" % points #count
