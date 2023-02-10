extends Node2D

#@export var debug_enabled : bool
# tile: 24x24, spaces: h=4 v=4

signal deck_initialized
signal deck_empty

signal tile_picked

var deck : Array = []
var next_tile : Node2D = null


func _ready():
	init_deck()
	
	# deck MUST contains at least one tile there, so check not needed + done inside function
	#$MarginContainer/VBoxContainer/NextTileDisplay.preview_tile(deck[0], Global.avail_tile_colors[deck[0].color])
	tile_picked.emit(deck[0])
	$MarginContainer/VBoxContainer/TmpAvailDeckTiles.deck_initialized(deck.size())
	$MarginContainer/VBoxContainer/MiniDeckDisplay.initialize(deck.size())
	#$MarginContainer/VBoxContainer/MiniDeckDisplay.tiles_in_deck = 
	#print("mdd="+str($MarginContainer/VBoxContainer/MiniDeckDisplay))


func init_deck():
	var tile : Node2D

	for shape in Global.avail_tile_shapes:
		# there are two of the same tiles in the deck, range (1,3) to loop twice
		# hardcoded value to update (tile_repetition/dupe_in_deck)
		for i in range(1,3):
			for color in Global.avail_tile_colors:
				tile = shape.instantiate()
				tile.modulate = Global.avail_tile_colors[color]
				tile.color = color
				deck.append(tile)
			
	#debug("Decktmp("+str(deck.size())+")=["+str(deck)+"]")
	deck.shuffle()
	Global.debug("ID DecktmpS("+str(deck.size())+")=["+str(deck)+"]")
	deck_initialized.emit(deck.size())

# how to call it ? signal ? intent to call method ?
func pick_next_tile() -> Node2D:
	var tile : Node2D = null
	
	if (deck.size() > 0):
		tile = deck.pop_front()	# every deck modification => signal to whoever needs it
		Global.debug("PiNT: (ds="+str(deck.size())+")  Tile=["+str(tile)+"]")
		
		# Preview next tile in deck
		tile_picked.emit(deck[0])
		# => emit signal, update ntd + minideck

	return tile

func preview_next_tile() -> Node2D:
	return deck[0]

#tmp, not here!
func old_preview_next_tile() -> Node2D:
	var tile : Node2D
	
	#if (following_tile != null):
	#	preview_tile.emit(following_tile, avail_tile_colors[following_tile.color])
	#	tile = following_tile
	if (deck.size() > 0):
		tile = deck[0]

		if (tile != null):
			##preview_tile.emit(tile, avail_tile_colors[tile.color])
			return tile
		else:
			return null
	else:
		#print("No more tile") +~emit signal nomoretile
		return null  
		# reset tile text or add an empty deck icon
