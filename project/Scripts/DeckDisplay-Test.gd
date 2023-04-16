extends Node2D

@onready var DeckDisplay = $MarginContainer/HBoxContainer/DeckDisplay

func _init():
	print("DDT: _init called")
	print("g.dbe="+str(Global.debug_enabled))
	Global.debug_enabled = true
	print("g.dbe="+str(Global.debug_enabled))

func _ready():
	Global.debug("DDT: _ready call")
	DeckDisplay.deck_is_ready()

func _on_button_pressed():
	Global.debug("button pressed")
	var tile = DeckDisplay.pick_next_tile()
	#tile.get_node("tile symbol").modulate = Global.avail_tile_colors[tile.color]
	Global.debug("test obp: tile picked="+str(tile))
	
	if tile != null:
		Global.debug("test obp:parent="+str(tile.get_parent())+" owner="+str(tile.owner))
		
		if tile.get_parent() != null:
			##tile.reparent($MarginContainer/HBoxContainer/VBoxContainer/TilePicked2)
			Global.debug("test obp: tile has a parent, remove it")
			tile.get_parent().remove_child(tile)
			Global.debug("test obp:parent="+str(tile.get_parent())+" owner="+str(tile.owner))
			#almost ok but doesn't display next tile !!
			
		#$MarginContainer/HBoxContainer/VBoxContainer/TilePicked.texture = tile.get_node("tile symbol").texture
		$MarginContainer/HBoxContainer/VBoxContainer/TilePicked2.add_child(tile)


func _on_deck_display_deck_initialized(deck : Array):
	Global.debug("deck init sig received: deck="+str(deck.size()))
	#var uniqs = deck.get_unique_tiles_set()


func _on_button_2_pressed():
	#use DeckDisplay.preview_next_tile
	var new_tile = DeckDisplay.preview_next_tile()
	Global.debug("PrevNT:parent="+str(new_tile.get_parent())+" owner="+str(new_tile.owner))
	#=> doesn't work very well, NTD not updated
	
	
#	var tile = DeckDisplay.pick_next_tile(false)
#	if tile != null:
#		Global.debug("test obp:parent="+str(tile.get_parent())+" owner="+str(tile.owner))
#
#		if tile.get_parent() != null:
#			Global.debug("test obp: duplicate tile")
#			new_tile = tile.duplicate()
#			#tile.get_parent().remove_child(tile)
#			#tile should be duplicated !!
#			Global.debug("test obp:parent="+str(new_tile.get_parent())+" owner="+str(new_tile.owner))

	$MarginContainer/HBoxContainer/VBoxContainer/TilePicked2.add_child(new_tile)

func _on_button_3_pressed():
	DeckDisplay.update()
