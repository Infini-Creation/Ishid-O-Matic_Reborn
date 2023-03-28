extends Control

#add pages count, like help prev/next or click = next then close
@export var scoreItemScene : PackedScene = preload("res://Scenes/HighScores/ScoreItem.tscn")
var currentPage : String


func _ready():
	var node
	
	#read global highscores table
	
	for idx in range(0,10):
		node = scoreItemScene.instantiate()
		node.init(idx+1, "aaa", 10, 10, 10)
		$"CenterContainer/VBoxContainer/HighScores-Items".add_child(node)
	
	pass

func _on_texture_button_pressed():
	hide()


func _on_previous_button_pressed():
	pass # Replace with function body.


func _on_next_button_pressed():
	pass # Replace with function body.
