extends Control

signal button_clicked(buttonID : int)

func _ready():
	pass

func _on_one_player_item_oneplayer_game_requested():
	Global.debug("1P game button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_1PGAME)

func _on_settings_item_settings_requested():
	Global.debug("Settings button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_SETTINGS)
	
func _on_two_players_item_twoplayers_game_requested():
	Global.debug("2P game button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_2PGAME)

func _on_high_scores_item_highscores_requested():
	Global.debug("HighSCores button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_HIGHSCORES)

func _on_help_item_help_requested():
	Global.debug("help button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_HELP)

func _on_about_item_about_requested():
	Global.debug("About button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_ABOUT)

func _on_quit_item_quit_requested():
	Global.debug("Quit button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_QUIT)
