extends Control

#script is now useless
func _on_deck_display_tile_picked(_tile : Node2D):
	pass
	#print("oddtp: get tile="+str(tile)+"  owner="+str(tile.owner)+" parent="+str(tile.get_parent()))

	#var tile = DeckDisplay.preview_next_tile()
	#add_child(tile)
