extends TextureRect

func _ready():
	#init with 1st tile in deck ?
	pass

# TODO: replace Node2D usage by texture directly, no need to use get_node then
func update_display(tile : Node2D, color : Color) -> void:
	if tile != null:
		#replace textureRect by empty control/container, put tile instance in it
		Global.debug("update_display: next Tile="+str(tile) + " color=" + tile.color + " shape=" + tile.shape)
		texture = tile.get_node("tile symbol").texture
		modulate = color

func _on_deck_display_tile_picked(_tile : Node2D):
	pass
	#update_display(tile, Global.avail_tile_colors[tile.color]) #tmp
