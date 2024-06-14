extends Control

var linkOpened : bool = false
var aboutText : String = Global.TRANSLATION_ERROR_MESSAGE_BBCODE


func _init():
	Global.debug("about: init called, at="+aboutText)


func _notification(what: int) -> void:
	Global.debug("about: _notification called, at="+aboutText.substr(100)+"  what="+str(what))


func _ready():	#or only when visible, ~the 1st time ??
	Global.debug("about: ready called, at="+aboutText)


func _on_texture_button_pressed():
	Global.debug("about: textbutton pressed")
	if !linkOpened:
		Global.debug("hide panel")
		hide()


func _on_rich_text_label_meta_clicked(meta):
	var err = OS.shell_open(meta)
	if err == OK:
		Global.debug("about: Opened link '%s' successfully!" % meta)
		linkOpened = true
	else:
		Global.debug("about: Failed opening the link '%s'!" % meta)
	linkOpened = false


func _on_action_button_pressed():
	Global.debug("about: textbutton pressed lo="+str(linkOpened))
	if !linkOpened:
		Global.debug("hide panel")
		hide()


func _on_close_button_pressed():
	Global.debug("about: close button pressed")
	hide()


func _on_visibility_changed():
	aboutText = Global.lp_translations[Global.TRANSLATION_ABOUT_PAGE][TranslationServer.get_locale()][0]

	Global.debug("about: vis chg: at="+aboutText)
	
	# ~not needed at all !!
	#if Global.translation_setting_updated[Global.TRANSLATION_ABOUT_PAGE] == true:
		#Global.debug("about: vis chg: lang updated")
		#aboutText = Global.TRANSLATION_ERROR_MESSAGE_BBCODE
#
		#aboutText = Global.lp_translations[Global.TRANSLATION_ABOUT_PAGE][TranslationServer.get_locale()][0]
		#Global.translation_setting_updated[Global.TRANSLATION_ABOUT_PAGE] = false
		#Global.debug("about: vis chg: lang updated well, flag reset")
#
	#Global.debug("about: vis chg end, at="+aboutText)
	$CenterContainer/VBoxContainer/TextureButton/RichTextLabel.text = aboutText
