extends Control

@onready var MainMenuButtons : PackedScene = preload("res://Scenes/Main Menu/Buttons.tscn")
@onready var SettingsButtons : PackedScene = preload("res://Scenes/SettingsMenu/Controls.tscn")
@onready var highScoresPage : PackedScene = preload("res://Scenes/high_scores.tscn")
@onready var gameScene : PackedScene = preload("res://Scenes/game.tscn")
@onready var gameTournamentPanel = $GameTournamentPanel
@onready var linksBox = $"HBoxC-Links"


var mainMenuButtons
var settingsMenu
var highScores
var game
var mainMenuSave : Node


signal launch_game(game_type : String)
signal audio_volume_updated(type: int, volume: int)

func _ready():
	#Global.debug_enabled = true #tmp
	#Global.load_config()
	#Global.debug("settings="+str(Global.settings))
	#
	$BackgroundTexture.texture = Global.main_menu_background[Global.season]
		#preload("res://Arts/Gfx/Menu/torii-spring.png")
	Global.debug("MainMenu: generate tile stripe")
	
	var raw_stone : PackedScene = preload("res://Scenes/tile.tscn")
	var tile : Tile = null
	var tilesStripe : Array = []
	var tilesDeck : Array = []
	var StripeIdx : int = 0
	var deckIdx : int = 0
	var stone_size_factor : float = 1.0

	#how many tile in stripes ? Which size ? => 16 full size
	tilesStripe.resize(16)
	tilesDeck.resize(36)

	# to replace, find some way to NOT deal with this directly using DeckDisplay or other
	for stone in Global.Stones["ushoe"].values():
		##print("MM==> stone size="+str(stone.get_size()))
		tile = raw_stone.instantiate()
		tile.get_node("Symbol").texture = stone
		
		# tmp need to know scale factor from size to 64 (size/64)
		if stone.get_size().x > 64.0:
			stone_size_factor = 64.0 / stone.get_size().x
			##print("Stone resize factor="+str(stone_size_factor))
			tile.get_node("Symbol").apply_scale(Vector2(stone_size_factor, stone_size_factor))
		
		tilesDeck[deckIdx] = tile
		deckIdx += 1

	tilesDeck.shuffle()
	Global.debug("td="+str(tilesDeck.size()))
	
	game = gameScene.instantiate()
	
	var idx = 0
	while idx <= 32:
		Global.debug("idx="+str(idx))
		tile = tilesDeck[idx]
		tile.position.x += 64 * StripeIdx + Global.TileOffset
		tile.position.y += Global.TileOffset
		$VBoxContainer/TopTilesStripe.add_child(tile)
		idx += 1
		
		tile = null
		tile = tilesDeck[idx]
		tile.position.x += 64 * StripeIdx + Global.TileOffset
		tile.position.y = $VBoxContainer/BottomTilesStripe.position.y + Global.TileOffset
		$VBoxContainer/BottomTilesStripe.add_child(tile)
		idx += 1
		StripeIdx += 1

	$VBoxContainer/CenterContainer/DummyLabel.hide()
	mainMenuButtons = MainMenuButtons.instantiate()
	Global.debug("add MM buttons")
	$VBoxContainer/CenterContainer.add_child(mainMenuButtons)
	mainMenuButtons.connect("button_clicked", _on_button_click_received)
	
	# Quit button is useless for Web export (does nothing) so hide it in such case
	if OS.get_name() == "Web":
		MainMenuButtons.hide_quit_button()


func _process(_delta: float) -> void:
	if $HelpPanel.visible == true or $AboutPanel.visible == true or $HallOfFamePanel.visible == true:
			linksBox.hide()
	else:
		linksBox.show()

	 
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
				Global.debug("remove MM buttons")
				$VBoxContainer/CenterContainer.remove_child(mainMenuButtons)
				##mainMenuButtons.queue_free() #may cause issue

			settingsMenu = SettingsButtons.instantiate()
			$VBoxContainer/CenterContainer.add_child(settingsMenu)
			settingsMenu.connect("button_clicked", _on_button_click_received)
			settingsMenu.connect("sound_volume_updated", _on_sound_volume_updated)
			settingsMenu.connect("language_updated", _on_language_updated)

		Global.ButtonIDs.BUTTON_HIGHSCORES:
			$HallOfFamePanel.show()

		Global.ButtonIDs.BUTTON_SETTINGS_BACK:
			$VBoxContainer/CenterContainer.remove_child(settingsMenu)
			##settingsMenu.queue_free()
			Global.debug("settings back to MM, add MM buttons")
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


func _on_language_updated(language : int):
	Global.debug("new lang set: "+str(language))
	Global.settings["language"] = language #tmp
	TranslationServer.set_locale(Global.LANGUAGE_SETTING[language])
	Global.translation_setting_updated[Global.TRANSLATION_ABOUT_PAGE] = true
	Global.translation_setting_updated[Global.TRANSLATION_HELP_PAGE] = true
	#add a global flag to "signal" any lang dependant panel to update 1st (help especially)
	# when to reset it ? when a game start ? or turn it into an array so all page can ack they get it ?
	
	
	Global.debug("reload mainMenuButtons scene")
	mainMenuButtons.queue_free()
	mainMenuButtons = MainMenuButtons.instantiate()
	mainMenuButtons.connect("button_clicked", _on_button_click_received)


func _on_game_tournament_panel_continue_tournament(cont : bool):
	Global.debug("tournament cont: "+str(cont))
	Global.continue_tournament = cont
	Global.debug("launch game now")
	launch_game.emit(Global.GAMETYPE_TOURNAMENT)


func _on_game_tournament_panel_back_to_menu():
	Global.debug("tournament cancelled")


func _on_xlink_button_pressed() -> void:
	Global.debug("X link pressed")
	Global.open_link(Global.X_LINK)

func _on_discord_link_button_pressed() -> void:
	Global.debug("Discord link pressed")
	Global.open_link(Global.DISCORD_LINK)
