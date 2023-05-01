extends Control

#func _ready():
	#print("GameOverPanel: _ready call")


func _on_game_game_is_over():
	print("GameWinPanel: game over signal received")
	
	show()
	#get_tree().paused = true

	# maybe display a game win panel and/or some festive animations
	#display highscore panel & register name + save => just emit button pressed or doing same as below



func _on_texture_button_pressed():
	print("GameWinPanel: button pressed, go back to main menu")
	#signal back game to exit ?
	# maybe: scene transition
	get_tree().change_scene_to_file(Global.previous_scene)
	
	#not here
	#TODO: check highscores if one > lowest at least go to page
	#TODO: put a new highscore line where it belongs
	#TODO: (ask name then update highscores data) = use defined name
	#TODO: go to main menu
