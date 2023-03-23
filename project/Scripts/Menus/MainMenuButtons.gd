extends Control

signal button_clicked(buttonID : int)

@onready var HintsMenuButton = $"ButtonsGroup/Hints-Language Row/Hints Type".get_popup()

func _ready():
	Global.debug_enabled = true #tmp
	HintsMenuButton.connect("id_pressed", self, "_on_popupMenu_Item_Selected")

func _on_accept_item_settings_save_requested():
	Global.debug("save settings clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_SETTINGS_SAVE)

func _on_back_item_settings_revert_requested():
	Global.debug("back clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_SETTINGS_BACK)

func _on_popupMenu_Item_Selected(id: int):
	print("hint selected="+HintsMenuButton.get_item_text(id))
