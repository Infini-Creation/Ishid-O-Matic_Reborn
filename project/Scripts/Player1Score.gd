extends RichTextLabel

func _on_grid_update_p_1_score(score : int):
	text = "%4d" % score
