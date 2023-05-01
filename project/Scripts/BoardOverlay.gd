extends Node2D

var CellCorners : Array
var BlinkingEffect : Tween

func _ready():
	#Global.debug("BO-_ready call") only called once as expected
	pass
#	BlinkingEffect = self.create_tween()
#	BlinkingEffect.set_loops()
#	BlinkingEffect.tween_property(self, "modulate", Color(1,1,1,0), 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
#	BlinkingEffect.tween_property(self, "modulate", Color(1,1,1,1), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
#	BlinkingEffect.play()

#add highlight mode for also do the same with 4ways matches
# color : temporary, later = params too as well as thickness and maybe antialias.
func _draw():
	for cell in CellCorners:
		draw_polyline(cell, Color(255,255,255, 100), 2.0, true)
		#timer.start()
		#make highlight blink, maybe using modulate on the whole node


func _on_game_highlight_board_cell(Coordinates : Array):
	CellCorners = Coordinates
	queue_redraw()
	
	Global.debug("start tween")
	BlinkingEffect = self.create_tween()
	BlinkingEffect.set_loops()
	BlinkingEffect.tween_property(self, "modulate", Color(1.0,1.0,1.0,0.0), 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	BlinkingEffect.tween_property(self, "modulate", Color(1.0,1.0,1.0,0.5), 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT_IN)
	BlinkingEffect.play()
	Global.debug("after tween play")
