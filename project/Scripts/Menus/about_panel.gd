extends Control


func _on_texture_button_pressed():
	hide()

#WIP
func _on_rich_text_label_meta_clicked(meta):
	var err = OS.shell_open(meta)
	if err == OK:
		print("Opened link '%s' successfully!" % meta)
	else:
		print("Failed opening the link '%s'!" % meta)
