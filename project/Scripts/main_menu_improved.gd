extends Control

@onready var MainMenuButtons : PackedScene = preload("res://Scenes/Main Menu/Buttons.tscn")
@onready var SettingsButtons : PackedScene = preload("res://Scenes/SettingsMenu/Controls.tscn")
@onready var highScoresPage : PackedScene = preload("res://Scenes/high_scores.tscn")
@onready var gameScene : PackedScene = preload("res://Scenes/game.tscn")
@onready var gameTournamentPanel = $GameTournamentPanel

var mainMenuButtons
var settingsMenu
var highScores
var game
var mainMenuSave : Node

signal launch_game(game_type : String)
signal audio_volume_updated(type: int, volume: int)

func _ready():
	Global.debug("MainMenu: generate tile stripe")
	
	var tile : Node2D = null
	var tilesStripe : Array = []
	var tilesDeck : Array = []
	var StripeIdx : int = 0
	var deckIdx : int = 0

	#how many tile in stripes ? Which size ? => 16 full size
	tilesStripe.resize(16)
	tilesDeck.resize(36)

	#later: to update/modify
	for shape in Global.avail_tile_shapes:
		for color in Global.avail_tile_colors:
			tile = Global.avail_tile_shapes[shape].instantiate()
			tile.get_node("tile symbol").modulate = Global.avail_tile_colors[color]
			tile.color = color
			tilesDeck[deckIdx] = tile
			deckIdx += 1

	tilesDeck.shuffle()
	Global.debug("td="+str(tilesDeck.size()))
	
	game = gameScene.instantiate()
	
	var idx = 0
	while idx <= 32:
		Global.debug("idx="+str(idx))
		tile = tilesDeck[idx]
		tile.position.x += 64 * StripeIdx + 32
		tile.position.y += 32
		$VBoxContainer/TopTilesStripe.add_child(tile)
		idx += 1
		
		tile = null
		tile = tilesDeck[idx]
		tile.position.x += 64 * StripeIdx +32
		tile.position.y = $VBoxContainer/BottomTilesStripe.position.y + 32
		$VBoxContainer/BottomTilesStripe.add_child(tile)
		idx += 1
		StripeIdx += 1

	$VBoxContainer/CenterContainer/DummyLabel.hide()
	mainMenuButtons = MainMenuButtons.instantiate()
	$VBoxContainer/CenterContainer.add_child(mainMenuButtons)
	mainMenuButtons.connect("button_clicked", _on_button_click_received)


func _on_button_click_received(buttonID : int):
	Global.debug("id="+str(buttonID))
	match buttonID:
	# Main menu buttons
		Global.ButtonIDs.BUTTON_1PGAME:
			launch_game.emit(Global.GAMETYPE_ONEPLAYER)

		Global.ButtonIDs.BUTTON_2PGAME:
			launch_game.emit(Global.GAMETYPE_TWOPLAYERS)

		Global.ButtonIDs.BUTTON_TOURNAMENT:
			gameTournamentPanel.show()

		Global.ButtonIDs.BUTTON_ENHANCED:
			launch_game.emit(Global.GAMETYPE_ENHANCED)
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
			settingsMenu.connect("sound_volume_updated", _on_sound_volume_updated)

		Global.ButtonIDs.BUTTON_HIGHSCORES:
			$HallOfFamePanel.show()

		Global.ButtonIDs.BUTTON_SETTINGS_BACK:
			$VBoxContainer/CenterContainer.remove_child(settingsMenu)
			$VBoxContainer/CenterContainer.add_child(mainMenuButtons)

		Global.ButtonIDs.BUTTON_SETTINGS_SAVE:
			Global.debug("call save settings HERE")
			
			# ==> + update sound volume and on/off status
			# gather settings (signal ?) or save in settings script directly
			#  would be better no need to transfert data here, global is global !
			# as above, go back to main menu ?

		_: 
			Global.debug("unhandled action")


#used?
func _on_help_panel_help_panel_closed():
	pass # Replace with function body.


func _on_sound_volume_updated(type: int, volume: int):
	if type == Global.AUDIO_TYPE_MUSIC:
		Global.debug("new music vol="+str(volume))
		audio_volume_updated.emit(type, volume)
	elif type == Global.AUDIO_TYPE_SOUNDEFFECT:
		Global.debug("new sndfx vol="+str(volume))
		audio_volume_updated.emit(type, volume)
	else:
		Global.debug("unhandled audio type: "+str(type))


func _on_game_tournament_panel_continue_tournament(cont : bool):
	Global.debug("tournament cont: "+str(cont))
	Global.continue_tournament = cont
	Global.debug("launch game now")
	launch_game.emit(Global.GAMETYPE_TOURNAMENT)


func _on_game_tournament_panel_back_to_menu():
	Global.debug("tournament cancelled")
