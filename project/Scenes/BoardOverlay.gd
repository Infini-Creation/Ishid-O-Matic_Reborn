extends Node2D

var CellCorners : Array

#add highlight mode for also do the same with 4ways matches
# color : temporary, later = params too as well as thickness and maybe antialias.
func _draw():
	for cell in CellCorners:
		draw_polyline(cell, Color(255,255,255, 100), 2.0, true)

func _on_grid_highlight_board_cell(Coordinates : Array):
	CellCorners = Coordinates
	queue_redraw()
