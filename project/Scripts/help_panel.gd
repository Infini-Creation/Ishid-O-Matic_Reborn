extends Control

@onready var PagesHolder : Array = [
	$CenterContainer/VBoxContainer/CenterContainer/Page1,
	$CenterContainer/VBoxContainer/CenterContainer/Page2,
	$CenterContainer/VBoxContainer/CenterContainer/Page3,
	$CenterContainer/VBoxContainer/CenterContainer/Page4,
	$CenterContainer/VBoxContainer/CenterContainer/Page5,
	$CenterContainer/VBoxContainer/CenterContainer/Page6,
	$CenterContainer/VBoxContainer/CenterContainer/Page7
]

signal help_panel_closed

var current_page : int = 0
var previous_page : int = 0
var max_pages : int = 0

func _ready():
	Global.debug("HelpPanel: _ready call")
	max_pages = PagesHolder.size() - 1

func update_page(prevPage : int, nextPage : int) -> void:
	Global.debug("HelpPanel: update page= " + str(prevPage) + " -> " + str(nextPage))
	PagesHolder[prevPage].hide()
	PagesHolder[nextPage].show()

# to remove eventually
func _on_texture_button_pressed():
	Global.debug("HelpPanel: button pressed, close it")
	help_panel_closed.emit()	#is this useful ?
	hide()
	#queue_free()

func _on_previous_page_pressed():
	Global.debug("HelpPanel: previous pressed")
	if current_page > 0:
		previous_page = current_page
		current_page -=1
		update_page(previous_page, current_page)

func _on_next_page_pressed():
	Global.debug("HelpPanel: next pressed")
	if current_page < max_pages:
		previous_page = current_page
		current_page += 1
		update_page(previous_page, current_page)


func _on_close_button_pressed():
	Global.debug("HelpPanel: button pressed, close it")
	help_panel_closed.emit()	#is this useful ?
	hide()
