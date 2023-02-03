extends Control

func _ready():
	print("GameOverPanel: _ready call")


func _on_grid_game_end(win : bool):
	print("GameOverPanel: game end signal received: w="+str(win))
	if (win == false):
		show()
		#get_tree().paused = true
	else:
		#display highscore panel & register name + save => just emit button pressed or doing same as below
		pass


func _on_texture_button_pressed():
	print("GameOverPanel: button pressed, go to highscores panel IF hs beat or main menu")
	#TODO: check highscores if one > lowest at least go to page
	#TODO: put a new highscore line where it belongs
	#TODO: ask name then update highscores data
	#TODO: go to main menu
