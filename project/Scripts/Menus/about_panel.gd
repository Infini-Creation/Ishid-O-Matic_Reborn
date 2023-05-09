extends Control

var linkOpened : bool = false

func _on_texture_button_pressed():
	Global.debug("textbutton pressed")
	if !linkOpened:
		Global.debug("hide panel")
		hide()


func _on_rich_text_label_meta_clicked(meta):
	var err = OS.shell_open(meta)
	if err == OK:
		Global.debug("Opened link '%s' successfully!" % meta)
		linkOpened = true
	else:
		Global.debug("Failed opening the link '%s'!" % meta)
	linkOpened = false


func _on_action_button_pressed():
	Global.debug("textbutton pressed lo="+str(linkOpened))
	if !linkOpened:
		Global.debug("hide panel")
		hide()
