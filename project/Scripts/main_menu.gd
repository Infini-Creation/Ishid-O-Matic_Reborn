extends Control

var avail_tile_shapes = [
	preload("res://Scenes/tileA.tscn"),
	preload("res://Scenes/tileB.tscn"),
	preload("res://Scenes/tileC.tscn"),
	preload("res://Scenes/tileD.tscn"),
	preload("res://Scenes/tileE.tscn"),
	preload("res://Scenes/tileF.tscn")
]

var avail_tile_colors = { "color1" : Color(221,0,221,1), "color2" : Color(0,204,204,1), "color3" : Color(221,0,0,1), "color4" : Color(17,85,255,1), "color5" : Color(0,170,0,1), "color6" : Color(238,170,0,1)}

func _ready():
	print("MainMenu: generate tile stripe")
	
	var tile : Node2D = null
	var tilesStripe : Array = []
	var tilesDeck : Array = []
	var StripeIdx : int = 0
	var deckIdx : int = 0

	#how many tile in stripes ? Which size ? => 16 full size
	tilesStripe.resize(16)
	tilesDeck.resize(36)

	for shape in avail_tile_shapes:
		for color in avail_tile_colors:
			tile = shape.instantiate()
			tile.modulate = avail_tile_colors[color]
			tile.color = color
			tilesDeck[deckIdx] = tile
			deckIdx += 1

	tilesDeck.shuffle()
	print("td="+str(tilesDeck.size()))
	
	var idx = 0
	while idx <= 32:
		# ko tile.transform.scaled(Vector2(0.5, 0.5))
		#tile.scale = Vector2(0.5, 0.5)
		print("idx="+str(idx))
		tile = tilesDeck[idx]
		tile.position.x += 64 * StripeIdx
		#tilesStripe[StripeIdx] = tile
		$VBoxContainer/TopTilesStripe.add_child(tile)
		idx += 1
		
		tile = null
		tile = tilesDeck[idx]
		tile.position.x += 64 * StripeIdx
		tile.position.y = $VBoxContainer/BottomTilesStripe.position.y
		$VBoxContainer/BottomTilesStripe.add_child(tile)
		idx += 1
		StripeIdx += 1
		
#	StripeIdx = 0
#	for idx in range(17,33):
#		# ko tile.transform.scaled(Vector2(0.5, 0.5))
#		#tile.scale = Vector2(0.5, 0.5)
#		#print("idx="+str(idx))
#		tile = tilesDeck[idx]
#		tile.position.x += 64 * StripeIdx
#		tile.position.y = $VBoxContainer/BottomTilesStripe.position.y
#		#tilesStripe[StripeIdx] = tile
#		StripeIdx += 1
#		$VBoxContainer/BottomTilesStripe.add_child(tile)
