extends Control

var linkOpened : bool = false
var aboutText : String = Global.TRANSLATION_ERROR_MESSAGE_BBCODE
var zoomAnimation : Tween = null
var zoomStatus : Array[bool] = [false, false, false]
var artistPicsOrigSizes : Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]

@onready var containerSize : Vector2 = Vector2.ZERO


func _init():
	Global.debug("about: init called, at="+aboutText.substr(50))


func _notification(what: int) -> void:
	Global.debug("about: _notification called, at="+aboutText.substr(50)+"  what="+str(what))


func _ready():	#or only when visible, ~the 1st time ??
	Global.debug("about: ready called, at="+aboutText.substr(50))
	containerSize = $CenterContainer/VBoxContainer.size
	Global.debug("about: ready contsize="+str(containerSize))
	artistPicsOrigSizes[0] = $CenterContainer/ArtistContainer/TextureRect.size
	artistPicsOrigSizes[1] = $CenterContainer/ArtistContainer/TextureRect2.size
	artistPicsOrigSizes[2] = $CenterContainer/ArtistContainer/TextureRect3.size


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

	##Global.debug("about: vis chg: at="+aboutText)
	
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
	$CenterContainer/VBoxContainer/TextureButton/CenterContainer/RichTextLabel.text = aboutText


func _on_artist_link_pressed() -> void:
	Global.debug("artpag: vis="+str($CenterContainer/ArtistContainer.visible))
	#not here !
	if $CenterContainer/ArtistContainer.visible == true:
		Global.debug("artpag: chg button behaviour & text")
	else:
		Global.debug("artpag: show artist credits panel")
	$CenterContainer/VBoxContainer/TextureButton/CloseButton.hide()
	$CenterContainer/ArtistContainer.show()
	$CenterContainer/VBoxContainer/TextureButton/CenterContainer.hide()
	$CenterContainer/VBoxContainer/TextureButton/artistLink.hide()


func _on_artist_link_gui_input(event: InputEvent) -> void:
	Global.debug("artlink button event="+str(event))


func _on_artist_page_back_pressed() -> void:
	Global.debug("art page back pressed")
	$CenterContainer/VBoxContainer/TextureButton/CloseButton.show()
	$CenterContainer/ArtistContainer.hide()
	$CenterContainer/VBoxContainer/TextureButton/CenterContainer.show()
	$CenterContainer/VBoxContainer/TextureButton/artistLink.show()
