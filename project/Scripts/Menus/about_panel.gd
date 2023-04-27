extends Control

var linkOpened : bool = false

func _on_texture_button_pressed():
	print("textbutton pressed")
	if !linkOpened:
		print("hide panel")
		hide()


func _on_rich_text_label_meta_clicked(meta):
	var err = OS.shell_open(meta)
	if err == OK:
		print("Opened link '%s' successfully!" % meta)
		linkOpened = true
	else:
		print("Failed opening the link '%s'!" % meta)
	linkOpened = false


func _on_action_button_pressed():
	print("textbutton pressed lo="+str(linkOpened))
	if !linkOpened:
		print("hide panel")
		hide()
