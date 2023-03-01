extends Label

func _on_update_player_fourways(count : int):
	#print("4Wcounter updated: " + str(count))
	text = "%2d" % count
