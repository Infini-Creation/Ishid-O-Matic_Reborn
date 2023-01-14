extends Node2D

@export var base_board : PackedVector2Array
@export var board_width : int
@export var board_height : int
@export var x_start : int
@export var y_start : int
@export var tile_size : int
@export var tile_colors : int
@export var tile_shapes : int
@export var player_name : String

var avail_tile_shapes = [
	preload("res://Scenes/tileA.tscn"),
	preload("res://Scenes/tileB.tscn"),
	preload("res://Scenes/tileC.tscn"),
	preload("res://Scenes/tileD.tscn"),
	preload("res://Scenes/tileE.tscn"),
	preload("res://Scenes/tileF.tscn")
]

#tmp
#var avail_tile_shapes = ["A", "B", "C", "D", "E", "F"]
#var avail_tile_colors = ["1", "2", "3", "4", "5", "6"]
var avail_tile_colors = { "color1" : Color(221,0,221,1), "color2" : Color(0,204,204,1), "color3" : Color(221,0,0,1), "color4" : Color(17,85,255,1), "color5" : Color(0,170,0,1), "color6" : Color(238,170,0,1)}

# could use only numbers for color as shape !

var tiles = []
var game_board : Array = []
var deck : Array = []
var next_tile : Node2D = null

var game_end : bool = false
var quit : bool = false

var FourWaysBonus = [25, 50, 100, 200, 400, 600, 800, 1000, 5000, 10000, 25000, 50000]

func _ready():
	randomize()
	game_board = make_2d_array()
	
	load_highscores()
	
	init_deck()
	init_board()

func _process(_delta):
	#later: take_time_from_deck (no more tile => win)
	#	check_move_avail (false => gameover)
	#	update_score
	
	if (!game_end and !quit):
		preview_next_tile(next_tile)
		var mpos : Vector2 = get_mouse_grid_position()
		##bad always work without delay/doing nothing when no click issued !
		if (check_position_ok(mpos)):
			print("position ok, proceed nt="+str(next_tile))
			if (next_tile == null):
				print("pick next tile")
				next_tile = pick_next_tile()
				print("tile="+str(next_tile))
			else:
				print("tile still not played: "+str(next_tile))

			if (next_tile != null):
				print ("tile ok, check")
				
				# here loop: while tile not put on board, stay here
				if check_adjacent_tiles(next_tile, mpos) == true:
					add_tile(mpos, next_tile)
					update_score()
					next_tile = null
				else:
					print ("Tile cannot be put in that cell, keep it in hand")
			else:
				print("No more tile")
				game_end = true


func make_2d_array():
	var array = []
	for i in board_width:
		array.append([])
		for j in board_height:
			array[i].append(null)
	return array


func grid_to_pixel(column, row):
	var new_x = x_start + column * tile_size
	var new_y = y_start + row * tile_size
	return Vector2(new_x, new_y)


func pixel_to_grid(x,y):
	var new_x = floor((x - x_start) / tile_size)
	var new_y = floor((y - y_start) / tile_size)
	return Vector2(new_x, new_y)


func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < board_width:
		if grid_position.y >= 0 && grid_position.y < board_height:
			return true
	return false


func get_mouse_grid_position() -> Vector2:
	var mouseGblPos = get_global_mouse_position()
	var mouseGridPos = pixel_to_grid(mouseGblPos.x, mouseGblPos.y)
	var mpos = Vector2(-1,-1)
	
	if Input.is_action_just_pressed("ui_touch"):
		print ("MouseGblPos:" + str(mouseGblPos) + "  MouseGridPos:" + str(mouseGridPos))
		if is_in_grid(mouseGridPos):
			print ("uitp-> In grid:" + str(mouseGridPos))
			mpos = mouseGridPos
			return mpos

	return Vector2(-1,-1)


func init_deck():
	var tile : Node2D

	for shape in avail_tile_shapes:
		for i in range(1,3):
			for color in avail_tile_colors:
				tile = shape.instantiate()
				tile.modulate = avail_tile_colors[color]
				tile.color = color
				
				#if (!starting_deck.has()):

				deck.append(tile)
			
	#print("Decktmp("+str(deck.size())+")=["+str(deck)+"]")
	deck.shuffle()
	print("ID DecktmpS("+str(deck.size())+")=["+str(deck)+"]")
	

func init_board():
	var shape_picked : Dictionary = {}
	var color_picked : Dictionary = {}
	var select_this_tile : bool = true
	var next_tile : Node2D = null
	var unique_tiles_set : Array = []
	var tileIndex : int = 0
	var iteration_needed : int = 0
	
	# TODO hardcoded values here to replace
	while (shape_picked.size() < 6 and color_picked.size() < 6):

		next_tile = pick_next_tile()
		iteration_needed += 1

		print("next tile c=" + next_tile.color + " s=" + next_tile.shape)
		print("colors picked="+str(color_picked))
		print("shapes picked="+str(shape_picked))
		
		if (color_picked.has(next_tile.color)):
			print("color : " + next_tile.color + " have already been picked, rejected")
			select_this_tile = false
		if (shape_picked.has(next_tile.shape)):
			print("shape : " + next_tile.shape + " have already been picked, rejected")
			select_this_tile = false

		print("tile selected="+str(select_this_tile))

		if (select_this_tile == true):
			print("tile["+str(next_tile)+"] added to unique tiles set")
			unique_tiles_set.append(next_tile)
			
			color_picked[next_tile.color] = 1
			shape_picked[next_tile.shape] = 1
		else:
			print("tile["+str(next_tile)+"] NOT added to unique tiles set")
			#~little helper put back tile to deck
			deck.push_back(next_tile)
			next_tile = null
			select_this_tile = true

	print("Iterations needed=" + str(iteration_needed))
	print("IB BB=["+str(base_board)+"]")

	#TODO: beware if initial game_board does not contains all tiles or more (game variant)
	for filled_cell in base_board:
		game_board[filled_cell.x][filled_cell.y] = unique_tiles_set[tileIndex]
		tileIndex += 1
		game_board[filled_cell.x][filled_cell.y].position = grid_to_pixel(filled_cell.x, filled_cell.y)
		print("put tile on:" + str(filled_cell))
		add_child(game_board[filled_cell.x][filled_cell.y])

	print("IB GB=" + str(game_board))


func check_position_ok(grid_position : Vector2) -> bool:
	#1. check cell is free
	#2. check tile follow the rules
	if (grid_position == Vector2(-1,-1)):
		##print("invalid cell")
		return false
	if game_board[grid_position.x][grid_position.y] == null:
		print("Cell["+str(grid_position)+"]:"+str(game_board[grid_position.x][grid_position.y]))
		return true
	else:
		print("Cell["+str(grid_position)+"] is occupied")
	
	return false


func pick_next_tile() -> Node2D:
	var tile : Node2D = null
	
	if (deck.size() > 0):
		tile = deck.pop_front()
		print("PiNT: (ds="+str(deck.size())+")  Tile=["+str(tile)+"]")
	return tile


func add_tile(grid_position : Vector2, tile : Node2D) -> void:
	print("AT: addtile called: pos=["+str(grid_position)+"] t=["+str(tile)+"]")
	tile.position = grid_to_pixel(grid_position.x, grid_position.y)
	game_board[grid_position.x][grid_position.y] = tile
	#also fill board data to check tiles later !
	add_child(tile)


func check_adjacent_tiles(tile : Node2D, grid_position : Vector2) -> bool:
	# no neighbor = move not allowed
	# else : check shape/color match
	
	var number_of_neighbor : int = 0
	var same_shape_neighbor : int = 0
	var same_color_neighbor : int = 0
	
	if grid_position.x > 0 and game_board[grid_position.x-1][grid_position.y] != null:
		number_of_neighbor += 1
		if game_board[grid_position.x-1][grid_position.y].shape == tile.shape:
			print("tile in x-1,y pos has same shape")
			same_shape_neighbor += 1
		if game_board[grid_position.x-1][grid_position.y].color == tile.color:
			print("tile in x-1,y pos has same color")
			same_color_neighbor += 1
	if grid_position.x < 11 and game_board[grid_position.x+1][grid_position.y] != null:
		number_of_neighbor += 1
		if game_board[grid_position.x+1][grid_position.y].shape == tile.shape:
			print("tile in x+1,y pos has same shape")
			same_shape_neighbor += 1
		if game_board[grid_position.x+1][grid_position.y].color == tile.color:
			print("tile in x+1,y pos has same color")
			same_color_neighbor += 1
	if grid_position.y > 0 and game_board[grid_position.x][grid_position.y-1] != null:
		number_of_neighbor += 1
		if game_board[grid_position.x][grid_position.y-1].shape == tile.shape:
			print("tile in x,y-1 pos has same shape")
			same_shape_neighbor += 1
		if game_board[grid_position.x][grid_position.y-1].color == tile.color:
			print("tile in x,y-1 pos has same color")
			same_color_neighbor += 1
	if grid_position.y < 7 and game_board[grid_position.x][grid_position.y+1] != null:
		number_of_neighbor += 1
		if game_board[grid_position.x][grid_position.y+1].shape == tile.shape:
			print("tile in x,y+1 pos has same shape")
			same_shape_neighbor += 1
		if game_board[grid_position.x][grid_position.y+1].color == tile.color:
			print("tile in x,y+1 pos has same color")
			same_color_neighbor += 1
	print ("CAT: NB="+str(number_of_neighbor)+" scn="+str(same_color_neighbor)+" ssn="+str(same_shape_neighbor))
	
	if (number_of_neighbor == 0):
		return false
	
	return true


# ~add arg to print something only one
# set flag to false outside (before the call), set it to true here at the end
#reset ti to false after tile picked
func preview_next_tile(next_tile : Node2D) -> void:
	var tile : Node2D
	var NextTileDisplay = get_tree().get_root().get_node("Game").get_node("UI").get_node("VBoxContainer").get_node("MarginContainer").get_node("NextTileDisplay")
	
	if (next_tile != null):
		tile = next_tile
	else:
		if (deck.size() > 0):
			tile = deck[0]
		#print("PrNT: (ds="+str(deck.size())+")Tile=["+str(tile)+"] c="+tile.color+" s="+tile.shape)
		##$UI/VBoxContainer/MarginContainer/NextTileDisplay.texture = tile.get_child(0).texture
		#print("PrNT: decktext=" + str(NextTileDisplay.texture)) #/VBoxContainer/MarginContainer/NextTileDisplay
		# ~signal NTD node from grid with text ref/color/shape and UI component just read tex and display it
		
		else:
			pass #print("No more tile")
			# reset tile text or add an empty deck icon

	if (tile != null):
		NextTileDisplay.texture = tile.get_node("Sprite2D").texture
		NextTileDisplay.modulate = avail_tile_colors[tile.color]


func update_score():
	pass


func game_over():
	pass


func save_highscore():
	pass


func load_highscores():
	pass
