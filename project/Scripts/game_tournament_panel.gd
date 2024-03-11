extends Control

signal continue_tournament(cont : bool)
signal back_to_menu
@onready var seedPanel = $CenterContainer/TextureRect2/VBoxContainerB

func _ready():
	Global.debug("GTP: transloc="+TranslationServer.get_locale())
	pass

func _on_yes_button_pressed():
	continue_tournament.emit(true)
	hide()

func _on_no_button_pressed():
	#continue_tournament.emit(false)
	$CenterContainer/TextureRect2/VBoxContainerA.hide()
	seedPanel.show()
	

func _on_cancel_button_pressed():
	back_to_menu.emit()
	hide()


func _on_b_ok_button_pressed():
	var spv = $CenterContainer/TextureRect2/VBoxContainerB/SeedInput2.value
	print("SPV="+str(spv))
	Global.tournamentSeed = spv
	#read spinbox value, check if it's ok then use it as seed
	continue_tournament.emit(false)
	hide()

#?? need to generate a new seed in this case
func _on_b_cancel_button_pressed():
	back_to_menu.emit()
	hide()


func _on_b_random_button_pressed() -> void:
	Global.tournamentSeed = 0
	continue_tournament.emit(false)
	back_to_menu.emit()
	hide()
