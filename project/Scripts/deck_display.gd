extends Node2D

# tile: 24x24, spaces: h=4 v=4

@export var gameType : String
var raw_stone : PackedScene = preload("res://Scenes/tile.tscn")

#signal deck_initialized
signal deck_empty

signal tile_picked
signal some_tiles_removed

var deck : Array = []
var next_tile : Node2D = null

@onready var previewNextTileDisplay = $MarginContainer/VBoxContainer/NextTileDisplay_Background/NextTileDisplay

func _ready():
	Global.debug("DeckDisplay: _ready called")
	init_deck()
	
	#abs path not very great, signal ?
	$MarginContainer/VBoxContainer/AvailDeckTiles_Background/AvailDeckTiles.deck_initialized(deck.size())


func init_deck():
	var tile : Tile = null
	
	deck.clear()
	if gameType == null or (gameType!= null and gameType != Global.GAMETYPE_ENHANCED):
		for stone : String in Global.Stones:	#need to be done twice!
			tile = raw_stone.instantiate()
			tile.get_node("Symbol").texture = Global.Stones[stone]
			tile.color = "color" + stone.right(1)
			tile.shape = "shape" + stone.left(1)
			Global.debug("tcolor=" + tile.color + "  tshape=" + tile.shape)
			deck.append(tile)
			deck.append(tile.duplicate())

		#debug("Decktmp("+str(deck.size())+")=["+str(deck)+"]")
		deck.shuffle()
		Global.debug("ID DecktmpS("+str(deck.size())+")=["+str(deck)+"]")
	else:
		deck.resize(2)

	#This is init deck so no check are required, it is safe to assume everything is set as it should be
	previewNextTileDisplay.get_node("TextureRect").texture = deck[0].get_node("Symbol").texture



#useless, to remove
func deck_is_ready():
	pass
	#tile_picked.emit(deck[0])


#to be used with NTD
func preview_next_tile() -> Node2D:
	var tile : Tile
	
	if deck.size() > 0:
		# to change here too
		tile = deck[0]

	return tile


func pick_next_tile() -> Node2D:
	var tile = preview_next_tile()
	if tile != null:
		previewNextTileDisplay.get_node("TextureRect").texture = tile.get_node("Symbol").texture  #.add_child(tile)
	
	if gameType == null or (gameType!= null and gameType != Global.GAMETYPE_ENHANCED):
		tile = deck.pop_front()
		Global.debug("PiNT: (ds="+str(deck.size())+")  Tile=["+str(tile)+"]")

		if (deck.size() > 0):
			Global.debug("TP sig emitted")
			tile_picked.emit(tile) #should be deck[0] ??
			#tile_picked.emit(deck[0])
		else:
			deck_empty.emit()
	else:
		#generate a random tile
		pass

	return tile


func get_deck_count() -> int:
	return deck.size()


func update_available_moves_counter(count : int) -> void:
	$MarginContainer/VBoxContainer/AvailDeckTiles_Background/AvailMovesCounter.update_counter(count)


func get_unique_tiles_set() -> Array:
	var shape_picked : Dictionary = {}
	var color_picked : Dictionary = {}
	var select_this_tile : bool = true
	var current_tile : Node2D = null
	var deck_index : int = 0
	var iteration_needed : int = 0
	
	var unique_tiles_set : Array = []

	while (shape_picked.size() < Global.tile_shapes and color_picked.size() < Global.tile_colors):

		current_tile = deck[deck_index]

		iteration_needed += 1

		Global.debug("guts: next tile (di="+str(deck_index)+") c=" + current_tile.color + " s=" + current_tile.shape)
		Global.debug("guts: colors picked="+str(color_picked))
		Global.debug("guts: shapes picked="+str(shape_picked))
		
		if (color_picked.has(current_tile.color)):
			Global.debug("color : " + current_tile.color + " have already been picked, rejected")
			select_this_tile = false
		if (shape_picked.has(current_tile.shape)):
			Global.debug("shape : " + current_tile.shape + " have already been picked, rejected")
			select_this_tile = false

		Global.debug("tile selected="+str(select_this_tile))

		if (select_this_tile == true):
			Global.debug("tile["+str(current_tile)+"] added to unique tiles set")
			unique_tiles_set.append(current_tile)
			
			deck.remove_at(deck_index)
			color_picked[current_tile.color] = 1
			shape_picked[current_tile.shape] = 1
		else:
			Global.debug("tile["+str(current_tile)+"] NOT added to unique tiles set (di="+str(deck_index)+")")
			
			deck_index += 1
			current_tile = null
			select_this_tile = true

	Global.debug("guts: Iterations needed=" + str(iteration_needed))
	some_tiles_removed.emit(unique_tiles_set.size())
	return unique_tiles_set


func _pick_next_tile(immediate_update_display : bool = true) -> Node2D:
	var tile : Node2D = null
	
	Global.debug("PNT called")
	if (deck.size() > 0):
		tile = deck.pop_front()	# every deck modification => signal to whoever needs it
		Global.debug("PiNT: (ds="+str(deck.size())+")  Tile=["+str(tile)+"]")
		
		# ISSUE here? deck_empty not connected to main game !!
		# Preview next tile in deck
		if immediate_update_display == true:
			if (deck.size() > 0):
				Global.debug("TP sig emitted")
				tile_picked.emit(deck[0])
			else:
				deck_empty.emit() #need to update deck display count !!
			
		# no more tile "item"
		# => emit signal, update ntd + minideck

	return tile


func _update() -> void:
	if (deck.size() > 0):
		Global.debug("TP sig emitted")
		tile_picked.emit(deck[0])
	else:
		deck_empty.emit()


func _preview_next_tile() -> Node2D:
	return deck[0].duplicate(DUPLICATE_SIGNALS|DUPLICATE_GROUPS|DUPLICATE_SCRIPTS)
