extends Control

signal is_closed

#TODO: animated score anim
# groing from 0 to score 1, add 4ways bonus, add rem tiles bonus
# with sounds & shaking
func _ready():
	#to remove
	Global.debug("final score panel ready")

func set_score(score: int) -> void:
	#first basic display of score
	$CenterContainer/TextureRect2/VBoxContainer/HBoxContainer/ScoreLabel.text = str(score)
	
func _on_button_pressed():
	hide()
	is_closed.emit()


# to remove
func _on_visibility_changed():
	Global.debug("final score panel vis changed:"+str(visible))
