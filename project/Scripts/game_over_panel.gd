extends Control

signal is_closed

func _ready():
	Global.debug("GameOverPanel: _ready call")


#useless/not use
func _on_game_game_is_over():
	Global.debug("GameOverPanel: game over signal received")
	
	show()
	#get_tree().paused = true

	# maybe display a game win panel and/or some festive animations
	#display highscore panel & register name + save => just emit button pressed or doing same as below


func _on_texture_button_pressed():
	Global.debug("GameOverPanel: button pressed, go back to main menu (not here)")
	#hide()
	#signal back game to exit ?
	is_closed.emit()
	# maybe: scene transition
	
	# not here, in origin
	##get_tree().change_scene_to_file(Global.previous_scene)
