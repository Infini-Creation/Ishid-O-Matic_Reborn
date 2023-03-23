extends Control

# use global to adjust volume and/or enable/disable music


func _on_texture_button_toggled(button_pressed):
	print("butt press="+str(button_pressed))
	#bp=true = music disabled, false = enabled
