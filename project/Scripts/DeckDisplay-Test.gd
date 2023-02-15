extends Node2D

@onready var DeckDisplay = $MarginContainer/HBoxContainer/DeckDisplay

func _ready():
	pass
	

func _on_button_pressed():
	var tile = DeckDisplay.pick_next_tile()
	print("tile="+str(tile))
	
	$MarginContainer/HBoxContainer/VBoxContainer/TilePicked.texture = tile.get_node("Sprite2D").texture
