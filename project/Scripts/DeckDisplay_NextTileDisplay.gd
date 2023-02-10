extends TextureRect

#global shape & color array/dictionnary

func _ready():
	pass

# TODO: replace Node2D usage by texture directly, no need to use get_node then
func update_display(tile : Node2D, color : Color) -> void:
	if tile != null:
		print("T="+str(tile) + "  color=" + tile.color + "  shape=" + tile.shape)
		texture = tile.get_node("Sprite2D").texture
		modulate = color


func _on_deck_display_tile_picked(tile : Node2D):
	update_display(tile, Global.avail_tile_colors[tile.color]) #tmp
