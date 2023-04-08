extends Node2D

var avail_tile_colors = [
	Color(221,0,221,1),
	Color(0,204,204,1),
	Color(221,0,0,1),
	Color(17,85,255,1),
	Color(0,170,0,1),
	Color(238,170,0,1)
]

var test_tile_texture = load("res://Arts/Gfx/Tiles/dummy sets/tile-A1.png")

var coloridx : int = 0
@onready var tile_content = $"HBoxContainer/Control/TileTest/tile symbol"
@onready var tile_base = $"HBoxContainer/Control/TileTest/tile border"

var componentRed : float
var componentGreen : float
var componentBlue : float


func _ready():
	tile_content.position = Vector2(-32,-32)
	tile_content.texture = test_tile_texture
	tile_content.modulate = avail_tile_colors[coloridx]

	componentRed = 0
	componentGreen = 0
	componentBlue = 0


func _on_timer_timeout():
	print("timer times out: colidx="+str(coloridx))
	coloridx += 1
	if coloridx >= avail_tile_colors.size():
		coloridx = 0
		
	tile_content.modulate = avail_tile_colors[coloridx]
	$Timer.stop()
	$Timer.start()


func _on_button_toggled(button_pressed):
	print("button pressed:"+str(button_pressed))
	if $Timer.is_stopped():
		$Timer.start()
	else:
		$Timer.stop()


func _on_modulate_color_component_r_update_color():
	componentRed = $"HBoxContainer/VBoxContainer/Modulate-Color-Component R".colorValue / 255.0
	print("R="+str(componentRed))
	tile_content.modulate = Color(componentRed, componentGreen, componentBlue, 1.0)

func _on_modulate_color_component_g_update_color():
	componentGreen = $"HBoxContainer/VBoxContainer/Modulate-Color-Component G".colorValue / 255.0
	print("R="+str(componentGreen))
	tile_content.modulate = Color(componentRed, componentGreen, componentBlue, 1.0)

func _on_modulate_color_component_b_update_color():
	componentBlue = $"HBoxContainer/VBoxContainer/Modulate-Color-Component B".colorValue / 255.0
	print("R="+str(componentBlue))
	tile_content.modulate = Color(componentRed, componentGreen, componentBlue, 1.0)
