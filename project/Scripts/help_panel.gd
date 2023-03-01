extends Control


@onready var PagesHolder : Array = [
	$CenterContainer/VBoxContainer/TextureButton/Page1,
	$CenterContainer/VBoxContainer/TextureButton/Page2,
	$CenterContainer/VBoxContainer/TextureButton/Page3,
	$CenterContainer/VBoxContainer/TextureButton/Page4,
	$CenterContainer/VBoxContainer/TextureButton/Page5,
	$CenterContainer/VBoxContainer/TextureButton/Page6
]

var current_page : int = 0
var previous_page : int = 0
var max_pages : int = 0

func _ready():
	Global.debug_enabled = true #tmp
	Global.debug("HelpPanel: _ready call")
	max_pages = PagesHolder.size() - 1

func update_page(prevPage : int, nextPage : int) -> void:
	Global.debug("HelpPanel: update page= " + str(prevPage) + " -> " + str(nextPage))
	PagesHolder[prevPage].hide()
	PagesHolder[nextPage].show()

# to remove eventually
func _on_texture_button_pressed():
	Global.debug("HelpPanel: button pressed, close it")
	queue_free()

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
