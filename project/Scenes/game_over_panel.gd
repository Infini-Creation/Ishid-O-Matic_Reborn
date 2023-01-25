extends Control

func _ready():
	print("GameOverPanel: _ready call")


func _on_grid_game_end(win : bool):
	print("GameOverPanel: game end signal received: w="+str(win))
	show()
	#get_tree().paused = true


func _on_texture_button_pressed():
	print("GameOverPanel: button pressed, go to highscores panel IF hs beat or main menu")
	#TODO: check highscores
	#TODO: ask name/update highscores data
	#TODO: go to main menu
