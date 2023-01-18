extends TextureRect

func _on_grid_preview_tile(tile : Node2D, color : Color):
	if tile != null:
		texture = tile.get_node("Sprite2D").texture
		modulate = color
