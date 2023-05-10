extends Node2D

@onready var DeckDisplay = $MarginContainer/HBoxContainer/DeckDisplay

func _init():
	print("DDT: _init called")


func _ready():
	Global.debug("DDT: _ready call")
	DeckDisplay.deck_is_ready()


func _on_button_pressed():
	Global.debug("button pressed")
	var tile = DeckDisplay.preview_next_tile()
	
	
		##DeckDisplay.pick_next_tile()
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
		$MarginContainer/HBoxContainer/VBoxContainer/TilePicked.add_child(tile)


func _on_deck_display_deck_initialized(deck : Array):
	Global.debug("deck init sig received: deck="+str(deck.size()))
	#var uniqs = deck.get_unique_tiles_set()


func _on_button_2_pressed():
	var new_tile = DeckDisplay.pick_next_tile()
	Global.debug("PNT:parent="+str(new_tile.get_parent())+" owner="+str(new_tile.owner))

	if new_tile != null:
		Global.debug("test obp:parent="+str(new_tile.get_parent())+" owner="+str(new_tile.owner))

		if new_tile.get_parent() != null:
			#Global.debug("test obp: duplicate tile")
			#new_tile = tile.duplicate()
			new_tile.get_parent().remove_child(new_tile)
			#tile should be duplicated !!
			Global.debug("test obp:parent="+str(new_tile.get_parent())+" owner="+str(new_tile.owner))

	$MarginContainer/HBoxContainer/VBoxContainer/TilePicked2.add_child(new_tile)

func _on_button_3_pressed():
	pass
	##DeckDisplay.update()


func _on_button_4_pressed():
	$MarginContainer/HBoxContainer/VBoxContainer/Label.text = "Deck Count="+str(DeckDisplay.get_deck_count())


func _on_deck_display_deck_empty():
	$MarginContainer/HBoxContainer/VBoxContainer/Button2.disabled = true


func _on_button_5_pressed():
	DeckDisplay.update_available_moves_counter(randi_range(0,8))
