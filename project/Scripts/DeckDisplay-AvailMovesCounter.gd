extends Label

var avail_moves : int = 0

func _ready():
	pass

func update_counter(moves : int) -> void:
	text = str(moves)
