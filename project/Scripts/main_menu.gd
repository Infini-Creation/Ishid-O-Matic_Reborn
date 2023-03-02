extends Control


func _ready():
	Global.debug_enabled = true #tmp
	Global.debug("MainMenu: generate tile stripe")
	
	var tile : Node2D = null
	var tilesStripe : Array = []
	var tilesDeck : Array = []
	var StripeIdx : int = 0
	var deckIdx : int = 0

	#how many tile in stripes ? Which size ? => 16 full size
	tilesStripe.resize(16)
	tilesDeck.resize(36)

	for shape in Global.avail_tile_shapes:
		for color in Global.avail_tile_colors:
			tile = shape.instantiate()
			tile.modulate = Global.avail_tile_colors[color]
			tile.color = color
			tilesDeck[deckIdx] = tile
			deckIdx += 1

	tilesDeck.shuffle()
	Global.debug("td="+str(tilesDeck.size()))
	
	var idx = 0
	while idx <= 32:
		# ko tile.transform.scaled(Vector2(0.5, 0.5))
		#tile.scale = Vector2(0.5, 0.5)
		Global.debug("idx="+str(idx))
		tile = tilesDeck[idx]
		tile.position.x += 64 * StripeIdx
		#tilesStripe[StripeIdx] = tile
		$VBoxContainer/TopTilesStripe.add_child(tile)
		idx += 1
		
		tile = null
		tile = tilesDeck[idx]
		tile.position.x += 64 * StripeIdx
		tile.position.y = $VBoxContainer/BottomTilesStripe.position.y
		$VBoxContainer/BottomTilesStripe.add_child(tile)
		idx += 1
		StripeIdx += 1
		
#	StripeIdx = 0
#	for idx in range(17,33):
#		# ko tile.transform.scaled(Vector2(0.5, 0.5))
#		#tile.scale = Vector2(0.5, 0.5)
#		#print("idx="+str(idx))
#		tile = tilesDeck[idx]
#		tile.position.x += 64 * StripeIdx
#		tile.position.y = $VBoxContainer/BottomTilesStripe.position.y
#		#tilesStripe[StripeIdx] = tile
#		StripeIdx += 1
#		$VBoxContainer/BottomTilesStripe.add_child(tile)


func _on_help_item_help_requested():
	Global.debug("help button clicked")
	#$VBoxContainer.hide()

	$VBoxContainer/MarginContainer.hide()
	$VBoxContainer/MarginContainer2.hide()
	$HelpPanel.show()

func _on_settings_item_settings_requested():
	Global.debug("Settings button clicked")

func _on_about_item_about_requested():
	Global.debug("About button clicked")

func _on_quit_item_quit_requested():
	Global.debug("Quit button clicked")
	get_tree().quit()

func _on_one_player_item_oneplayer_game_requested():
	Global.debug("1P game button clicked")

func _on_two_players_item_twoplayers_game_requested():
	Global.debug("2P game button clicked")

func _on_high_scores_item_highscores_requested():
	Global.debug("HighSCores button clicked")

func _on_help_panel_help_panel_closed():
	#$VBoxContainer.show()
	$VBoxContainer/MarginContainer.show()
	$VBoxContainer/MarginContainer2.show()
