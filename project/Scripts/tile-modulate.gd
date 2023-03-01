extends Node2D

var avail_tile_colors = [
	Color(221,0,221,1),
	Color(0,204,204,1),
	Color(221,0,0,1),
	Color(17,85,255,1),
	Color(0,170,0,1),
	Color(238,170,0,1)
]

var coloridx : int = 0
@onready var tile = $Tile/Sprite2D

func _ready():
	tile.modulate = avail_tile_colors[coloridx]


func _on_timer_timeout():
	print("timer times out: colidx="+str(coloridx))
	coloridx += 1
	if coloridx >= avail_tile_colors.size():
		coloridx = 0
		
	tile.modulate = avail_tile_colors[coloridx]
	$Timer.stop()
	$Timer.start()
