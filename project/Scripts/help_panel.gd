extends Control

const PAGESCOUNT : int = 7

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
var helpText : String = "[center]Translation Error ![/center]"

func _ready():
	Global.debug("HelpPanel: _ready call")
	max_pages = PagesHolder.size() - 1
	
	for pageIdx in range(0, 7):
		helpText = Global.lp_translations[Global.TRANSLATION_HELP_PAGE][TranslationServer.get_locale()][pageIdx]
		Global.debug("pidx=["+str(pageIdx)+"] t=["+helpText+"]")
		PagesHolder[pageIdx].text = helpText


func update_page(prevPage : int, nextPage : int) -> void:
	Global.debug("HelpPanel: update page= " + str(prevPage) + " -> " + str(nextPage))
	PagesHolder[prevPage].hide()
	#bad this way, need to init translation somewhere, fill misisng data with non fatal stuff
	PagesHolder[nextPage].text = Global.lp_translations[Global.TRANSLATION_HELP_PAGE][TranslationServer.get_locale()][nextPage]

	Global.debug("up currpg("+str(nextPage)+") len="+str(PagesHolder[nextPage].text.length()))
	Global.debug("up currpg("+str(nextPage)+") label RS="+str(PagesHolder[nextPage].size))
	if (PagesHolder[nextPage].size.y) > 510:
		Global.debug("up currpg("+str(nextPage)+") label set font size to 16")
		PagesHolder[nextPage].set("theme_override_font_sizes/font_size", 16)
	#cent cont y size 510 px std, 548 too high => reduce font size for ??? can it be done on the fly ?
		
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


func _on_visibility_changed():
	Global.debug("help vis chg")
	
	if visible == false:
		if current_page != 0:
			Global.debug("help: reset curr page")
			current_page = 0
			#update_page(0, 1) #not enough !!
			for pageIdx in range(0, max_pages + 1):
				PagesHolder[pageIdx].hide()
			PagesHolder[0].show()
		#doing this way make old page stay behind new one !!
		
	#HERE==> refresh tr IF NEEDED
	
	#var pageIdx : int = 1
	#var nodePath : String = "CenterContainer/VBoxContainer/CenterContainer/Page"
#
	Global.debug("help: upd tr ??   curpg="+str(current_page)) #YES!! IF settings has changed !
	#PH array not yet initialized here ?? => called BEFORE _ready !!
	# need to wait ready has been called/called after or call this in ready instead
	if max_pages > 0 :
		#occured only for page 0 !
		PagesHolder[current_page].text = Global.lp_translations[Global.TRANSLATION_HELP_PAGE][TranslationServer.get_locale()][current_page]
		Global.debug("currpg("+str(current_page)+") len="+str(PagesHolder[current_page].text.length()))
		Global.debug("currpg("+str(current_page)+") label RS="+str(PagesHolder[current_page].size))
		# little hack to make error message looks consistent with other as the text on first
		# help page is longer than others, font size has been set to 18 on this one only.
		if current_page == 0 and PagesHolder[current_page].text.length() < 100:
			##PagesHolder[current_page].font_size = 20
			Global.debug("set size to 20")
			$CenterContainer/VBoxContainer/CenterContainer/Page1.set("theme_override_font_sizes/font_size", 20)
		else:
			Global.debug("set size to 18")
			$CenterContainer/VBoxContainer/CenterContainer/Page1.set("theme_override_font_sizes/font_size", 18)
