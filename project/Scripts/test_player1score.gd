extends Control

@onready var P1sPanel = $VBoxContainer/Player1_subPanel
var score : int = 0
var fourways : int = 0
var points : int

func _ready():
	print("ready called")
	
func _on_score_button_pressed():
	points = randi_range(1,4)
	score += points
	print("score=" + str(score))
	P1sPanel.update_player_score(score)

func _on_four_ways_button_pressed():
	fourways += 1
	P1sPanel.update_player_fways_counter(fourways)
