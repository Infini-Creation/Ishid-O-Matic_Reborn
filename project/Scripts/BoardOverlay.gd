extends Node2D

var CellCorners : Array
var BlinkingEffect : Tween

func _ready():
	BlinkingEffect = self.create_tween()
	BlinkingEffect.set_loops()
	BlinkingEffect.tween_property(self, "modulate", Color(0.5,0.5,0.5,0.0), 1.0).set_delay(0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	BlinkingEffect.tween_interval(0.5)
	BlinkingEffect.tween_property(self, "modulate", Color(1.0,1.0,1.0,1.0), 1.0).set_delay(0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	BlinkingEffect.play()


func _draw():
#	BlinkingEffect = self.create_tween()
#	BlinkingEffect.set_loops()
#	BlinkingEffect.tween_property(self, "modulate", Color(0.8,0.8,0.8,0.1), 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
#	#BlinkingEffect.tween_property(self, "modulate", Color(1.0,1.0,1.0,0.9), 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT_IN)
#	BlinkingEffect.play()
	
	for cell in CellCorners:
		draw_polyline(cell, Color(255,255,255, 100), 2.0, true)


func _on_game_highlight_board_cell(Coordinates : Array):
	CellCorners = Coordinates
	queue_redraw()
