extends Control

var linkOpened : bool = false
var aboutText : String = Global.TRANSLATION_ERROR_MESSAGE_BBCODE


func _init():
	Global.debug("about: init called, at="+aboutText.substr(50))


func _notification(what: int) -> void:
	Global.debug("about: _notification called, at="+aboutText.substr(50)+"  what="+str(what))


func _ready():	#or only when visible, ~the 1st time ??
	Global.debug("about: ready called, at="+aboutText.substr(50))


func _on_texture_button_pressed() -> void:
	Global.debug("about: textbutton pressed")
	if !linkOpened:
		Global.debug("hide panel")
		hide()


func _on_rich_text_label_meta_clicked(meta) ->  void:
	linkOpened = Global.open_link(meta)


func _on_action_button_pressed() -> void:
	Global.debug("about: textbutton pressed lo="+str(linkOpened))
	if !linkOpened:
		Global.debug("hide panel")
		hide()


func _on_close_button_pressed() -> void:
	Global.debug("about: close button pressed")
	hide()


func _on_visibility_changed() -> void:
	aboutText = Global.lp_translations[Global.TRANSLATION_ABOUT_PAGE][TranslationServer.get_locale()][0]

	##Global.debug("about: vis chg: at="+aboutText)

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
