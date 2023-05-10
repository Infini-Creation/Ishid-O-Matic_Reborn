extends Control

@export var labelPlayerIdx : String
@export var defaultPlayerName : String

signal settings_updated(String)

func _ready():
	$PanelContainer/HBoxContainer/Label.text = labelPlayerIdx
	$PanelContainer/HBoxContainer/LineEdit.placeholder_text = defaultPlayerName


func load_settings(updated_player_name : String) -> void:
	if updated_player_name != null and updated_player_name != "":
		$PanelContainer/HBoxContainer/LineEdit.text = updated_player_name


func _on_line_edit_text_submitted(new_text):
	Global.debug("Player's name is set to: "+new_text)
	settings_updated.emit(new_text)
