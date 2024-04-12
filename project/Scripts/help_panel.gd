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
	
	#fill the array as it should be in global/origin, no tests here
	if Global.lp_translations.has(Global.TRANSLATION_HELP_PAGE):
		if Global.lp_translations[Global.TRANSLATION_HELP_PAGE].has(TranslationServer.get_locale()):
			Global.debug("lang is avail: " +TranslationServer.get_locale())
			Global.debug("nb page: "+str(Global.lp_translations[Global.TRANSLATION_HELP_PAGE][TranslationServer.get_locale()].size()))
			
			if Global.lp_translations[Global.TRANSLATION_HELP_PAGE][TranslationServer.get_locale()].size() > 0:
				for pageIdx in range(0, 7):
					helpText = Global.lp_translations[Global.TRANSLATION_HELP_PAGE][TranslationServer.get_locale()][pageIdx]
					Global.debug("pidx=["+str(pageIdx)+"] t=["+helpText+"]")
					PagesHolder[pageIdx].text = helpText
			else:
				pass
		else:
			pass
	else:
		pass

func update_page(prevPage : int, nextPage : int) -> void:
	Global.debug("HelpPanel: update page= " + str(prevPage) + " -> " + str(nextPage))
	PagesHolder[prevPage].hide()
	#bad this way, need to init translation somewhere, fill misisng data with non fatal stuff
	if Global.lp_translations["HELP"][TranslationServer.get_locale()].size() > 0:
		# also check page count idx
		PagesHolder[nextPage].text = Global.lp_translations["HELP"][TranslationServer.get_locale()][nextPage]
	else:
		PagesHolder[nextPage].text = Global.TRANSLATION_ERROR_MESSAGE
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
	Global.debug("help: upd tr ??") #YES!! IF settings has changed !
	#if Global.lp_translations.has("HELP"):
		#if Global.lp_translations["HELP"].has(TranslationServer.get_locale()):
			#Global.debug("lang is avail: " +TranslationServer.get_locale())
			#Global.debug("nb page: "+str(Global.lp_translations["HELP"][TranslationServer.get_locale()].size()))
			#
			##or here only tr currentp age but issue, panel need to be closed/opened
			## or in page browsing, using sub func
			#if Global.lp_translations["HELP"][TranslationServer.get_locale()].size() > 0:
				#for pageIdx in range(1, 8):
					#helpText = Global.lp_translations["HELP"][TranslationServer.get_locale()][pageIdx - 1]
					#nodePath += str(pageIdx) #+ ".text"
					#Global.debug("nodep=["+nodePath+"] t=["+helpText+"]")
					#PagesHolder[pageIdx].text = helpText
					##$CenterContainer/VBoxContainer/CenterContainer/Page+str(pageIdx).text = helpText
			#else:
				#pass
		#else:
			#pass
	#else:
		#pass

	pass
