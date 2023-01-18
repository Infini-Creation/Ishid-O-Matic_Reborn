extends Label

var tiles_count : int

func _on_grid_deck_initialized(number_of_tiles : int):
	tiles_count = number_of_tiles
	text = str(number_of_tiles)

func _on_grid_tile_picked():
	tiles_count -= 1
	text = str(tiles_count)
