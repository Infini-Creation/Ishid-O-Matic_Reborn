extends Control

signal is_closed

#func _ready():
	#print("GameOverPanel: _ready call")


func _on_game_game_is_over():
	print("GameWinPanel: game over signal received")
	show()

	# maybe display a game win panel and/or some festive animations
	#display highscore panel & register name + save => just emit button pressed or doing same as below


func _on_texture_button_pressed():
	print("GameWinPanel: button pressed, go back to main menu")
	#signal back game to exit ?
	is_closed.emit()
