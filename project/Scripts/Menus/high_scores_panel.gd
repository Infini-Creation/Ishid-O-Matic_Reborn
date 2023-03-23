extends Control

#add pages count, like help prev/next or click = next then close
@export var scoreItemScene : PackedScene = preload("res://Scenes/HighScores/ScoreItem.tscn")


func _ready():
	#add dummy entries
	var node : Control
	
	for idx in range(0,2):
		node = scoreItemScene.instantiate()
		$"CenterContainer/VBoxContainer/HighScores-Items".add_child(node)
	
	pass

func _on_texture_button_pressed():
	hide()
