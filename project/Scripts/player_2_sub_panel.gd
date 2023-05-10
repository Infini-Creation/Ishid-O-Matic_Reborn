extends Control

func _ready():
	$"Player2 Score".text = "----"
	$"FourWays Counter".text = "--"

func update_player_score(points: int) -> void:
	$"Player2 Score".text = "%4d" % points

func update_player_fways_counter(points: int) -> void:
	$"FourWays Counter".text = "%2d" % points
