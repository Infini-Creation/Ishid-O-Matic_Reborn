extends Control

signal continue_tournament(cont : bool)
signal back_to_menu
const default_label : String = "Do you want to continue the current tournament or to start a new one ?"

#label setup thing is useless
func _ready():
	$CenterContainer/TextureRect2/VBoxContainer/Label.text = default_label

func setup_label(labelToUse : String)  -> void:
	if labelToUse != null and labelToUse != "":
		$CenterContainer/TextureRect2/VBoxContainer/Label.text = labelToUse
	else:
		$CenterContainer/TextureRect2/VBoxContainer/Label.text = default_label

func _on_yes_button_pressed():
	continue_tournament.emit(true)
	hide()

func _on_no_button_pressed():
	continue_tournament.emit(false)
	hide()

func _on_cancel_button_pressed():
	back_to_menu.emit()
	hide()
