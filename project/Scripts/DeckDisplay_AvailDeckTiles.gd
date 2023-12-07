extends Label

var tiles_count : int

func _ready():
	pass

func deck_initialized(number_of_tiles : int):
	Global.debug("tmpdis: deck init => "+str(number_of_tiles)) #Global.debug
	tiles_count = number_of_tiles
	text = str(number_of_tiles)

# better not to use signal from button
# deck SHOULD manage itself

func _on_deck_display_tile_picked(_tile : Node2D):
	Global.debug("tmpdis: tilepicked sig received")
	tiles_count -= 1
	text = str(tiles_count)

func _on_deck_display_deck_empty():
	text = "Empty"


func _on_deck_display_some_tiles_removed(count : int):
	Global.debug("tmpdis: sometilesremoved sig received")
	tiles_count -= count
	text = str(tiles_count)
