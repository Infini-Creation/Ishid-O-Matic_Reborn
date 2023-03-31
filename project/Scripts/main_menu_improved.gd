extends Control

@onready var MainMenuButtons : PackedScene = preload("res://Scenes/Main Menu/Buttons.tscn")
@onready var SettingsButtons : PackedScene = preload("res://Scenes/SettingsMenu/Controls.tscn")
@onready var highScoresPage : PackedScene = preload("res://Scenes/high_scores.tscn")

var mainMenuButtons
var settingsMenu
var highScores

func _ready():
	#Global.debug_enabled = true #tmp
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
		Global.debug("idx="+str(idx))
		tile = tilesDeck[idx]
		tile.position.x += 64 * StripeIdx
		$VBoxContainer/TopTilesStripe.add_child(tile)
		idx += 1
		
		tile = null
		tile = tilesDeck[idx]
		tile.position.x += 64 * StripeIdx
		tile.position.y = $VBoxContainer/BottomTilesStripe.position.y
		$VBoxContainer/BottomTilesStripe.add_child(tile)
		idx += 1
		StripeIdx += 1

	$VBoxContainer/CenterContainer/DummyLabel.hide()
	mainMenuButtons = MainMenuButtons.instantiate()
	$VBoxContainer/CenterContainer.add_child(mainMenuButtons)
	# need to connect signal here by code !
	mainMenuButtons.connect("button_clicked", _on_button_click_received)


func _on_button_click_received(buttonID : int):
	Global.debug("id="+str(buttonID))
	match buttonID:
	# Main menu buttons
		Global.ButtonIDs.BUTTON_1PGAME:
			#setup main game and run it
			pass
		Global.ButtonIDs.BUTTON_2PGAME:
			pass
		Global.ButtonIDs.BUTTON_TOURNAMENT:
			pass #TODO
			#display a special Coming Soon panel for this
		Global.ButtonIDs.BUTTON_ABOUT:
			$AboutPanel.show()
		Global.ButtonIDs.BUTTON_HELP:
			$HelpPanel.show()

		Global.ButtonIDs.BUTTON_QUIT:
			get_tree().quit()

		Global.ButtonIDs.BUTTON_SETTINGS:
			if mainMenuButtons != null: #or is in tree
				$VBoxContainer/CenterContainer.remove_child(mainMenuButtons)

			settingsMenu = SettingsButtons.instantiate()
			$VBoxContainer/CenterContainer.add_child(settingsMenu)
			settingsMenu.connect("button_clicked", _on_button_click_received)
			
		Global.ButtonIDs.BUTTON_HIGHSCORES:
			$HallOfFamePanel.show()
			#if mainMenuButtons != null: #or is in tree
			#	$VBoxContainer/CenterContainer.remove_child(mainMenuButtons)
			
			#	highScores = highScoresPage.instantiate()
			#	$VBoxContainer/CenterContainer.add_child(highScores)
				#settingsMenu.connect("button_clicked", _on_button_click_received)
	# Settings Menu Buttons
		Global.ButtonIDs.BUTTON_SETTINGS_BACK:
			$VBoxContainer/CenterContainer.remove_child(settingsMenu)
			$VBoxContainer/CenterContainer.add_child(mainMenuButtons)

		Global.ButtonIDs.BUTTON_SETTINGS_SAVE:
			Global.debug("call save settings HERE")
			# add feedback settings save successfully (small popup label)
			
			# gather settings (signal ?) or save in settings script directly
			#  would be better no need to transfert data here, global is global !
			# as above, go back to main menu ?
			pass

	# HighScores Menu Buttons
		_: 
			Global.debug("unhandled action")


func _on_help_panel_help_panel_closed():
	pass # Replace with function body.
