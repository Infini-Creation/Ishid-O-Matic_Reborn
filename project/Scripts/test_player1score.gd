extends Control

signal p1score_updated
signal p14wcounter_updated

@onready var P1sPanel = $VBoxContainer/Player1_subPanel

func _ready():
	print("ready called")
	
func _on_score_button_pressed():
	var score = randi_range(1,4)
	print("score=" + str(score))
	P1sPanel.update_player_score(score)

func _on_four_ways_button_pressed():
	P1sPanel.update_player_fways_counter(1)
