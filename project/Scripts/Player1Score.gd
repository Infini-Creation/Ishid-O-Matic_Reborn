extends Label

func _on_update_player_score(score : int):
	text = "%4d" % score
