extends Control

var prevTile : Node2D

func _on_deck_display_tile_picked(tile : Node2D):
	print("oddtp: get tile="+str(tile)+"  owner="+str(tile.owner)+" parent="+str(tile.get_parent()))
	if prevTile != null:
		print("pvTile="+str(prevTile)+" own="+str(prevTile.owner)+" parent="+str(tile.get_parent()))
		remove_child(prevTile)
		
	if prevTile != null and prevTile == tile:
		print("1st step case")
	else:
		add_child(tile)
	prevTile = tile
