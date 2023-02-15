extends GridContainer

# signal remove tile
# signal init => create cols/rows of mini tiles (def 6/11)
#	need minitiles text + gap
@export var mini_tile : Texture = null
@onready var tiles_in_deck : int = 0

func _ready():
	# init tiles_in_deck 1st
	pass
	
func initialize(tiles : int):
	print("init-TID="+str(tiles))
	tiles_in_deck = tiles
	init_mini_deck(tiles_in_deck)

# GridCont ONLY work with Control node, not all node
# one way is to use an hidden gridcont to get coordinates of nodes
# then get back coordinates to put node2D in right location
# IF each position is actually absolute and different !
func init_mini_deck(number_of_tiles : int) -> void:
	print("imd-start="+str(number_of_tiles)+"  col="+str(columns) + "  row="+str(int(number_of_tiles / columns)))
	if tiles_in_deck > 0:
		var tilecount = 0
		for row in number_of_tiles / columns:
			for column in columns:
				tilecount += 1
				var tile : TextureRect = TextureRect.new()
				tile.texture = mini_tile
				tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				# should create a minitile scene and instantiate it here, texture would be set there, not
				# in this display
				add_child(tile)
		print("tc="+str(tilecount))

	#for child in get_children():
	#	print("node("+str(child)+") pos="+str(child.position))

func remove_tile():
	# call by signal
	# get 1st member in grid and remove it
	var nodeIdx : int = get_child_count(false)
	print("remove tile called, gcc="+str(nodeIdx))
	if nodeIdx > 0:
		#print_tree()
		var node = get_child(0, false)
		print("node ["+str(node)+"] will be removed")
		remove_child(node) #that's works but remove from the end not the top
		#+ it rearange the other containers to fit the whole space... not great effect
		# better to make my own grid I guess
		#queue_free() => remove ALL nodes !!
	

func _on_deck_display_tile_picked(_tile : Node2D):
	print("mdd-sig received")
	remove_tile()
