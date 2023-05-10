extends Control

@export var playerIdx : int = 1
@export var playerLabel : String

func _ready():
	$"Background/VBoxContainer/Player Label".text = playerLabel
	$"Background/VBoxContainer/HBoxContainer/Player Score".text = "----"
	$"Background/VBoxContainer/HBoxContainer/FourWays Counter".text = "--"

func update_player_score(points: int) -> void:
	$"Background/VBoxContainer/HBoxContainer/Player Score".text = "%4d" % points

func update_player_fways_counter(points: int) -> void:
	$"Background/VBoxContainer/HBoxContainer/FourWays Counter".text = "%2d" % points
