extends Control

signal playtutorial(confirm : bool)

func _ready():
	Global.debug("GPTP: transloc="+TranslationServer.get_locale())
	
func _on_yes_button_pressed():
	playtutorial.emit(true)

func _on_no_button_pressed():
	playtutorial.emit(false)
