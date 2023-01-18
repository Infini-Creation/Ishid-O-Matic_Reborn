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

signal deck_initialized
signal tile_picked
signal preview_tile

var avail_tile_colors = { "color1" : Color(221,0,221,1), "color2" : Color(0,204,204,1), "color3" : Color(221,0,0,1), "color4" : Color(17,85,255,1), "color5" : Color(0,170,0,1), "color6" : Color(238,170,0,1)}

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
				
				# update deck & next tile display ONLY when tile is actually put on the board
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
	deck_initialized.emit(deck.size())
	

func init_board():
	var shape_picked : Dictionary = {}
	var color_picked : Dictionary = {}
	var select_this_tile : bool = true
	var current_tile : Node2D = null
	var unique_tiles_set : Array = []
	var tileIndex : int = 0
	var deck_index : int = 0
	var iteration_needed : int = 0
	
	# TODO hardcoded values here to replace
	while (shape_picked.size() < 6 and color_picked.size() < 6):

		current_tile = deck[deck_index]
		##deck_index += 1

		iteration_needed += 1

		print("next tile (di="+str(deck_index)+") c=" + current_tile.color + " s=" + current_tile.shape)
		print("colors picked="+str(color_picked))
		print("shapes picked="+str(shape_picked))
		
		if (color_picked.has(current_tile.color)):
			print("color : " + current_tile.color + " have already been picked, rejected")
			select_this_tile = false
		if (shape_picked.has(current_tile.shape)):
			print("shape : " + current_tile.shape + " have already been picked, rejected")
			select_this_tile = false

		print("tile selected="+str(select_this_tile))

		if (select_this_tile == true):
			print("tile["+str(current_tile)+"] added to unique tiles set")
			unique_tiles_set.append(current_tile)
			
			deck.remove_at(deck_index)
			color_picked[current_tile.color] = 1
			shape_picked[current_tile.shape] = 1
		else:
			print("tile["+str(current_tile)+"] NOT added to unique tiles set (di="+str(deck_index)+")")
			
			deck_index += 1
			current_tile = null
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
		tile_picked.emit()

	return tile


func add_tile(grid_position : Vector2, tile : Node2D) -> void:
	print("AT: addtile called: pos=["+str(grid_position)+"] t=["+str(tile)+"]")
	tile.position = grid_to_pixel(grid_position.x, grid_position.y)
	game_board[grid_position.x][grid_position.y] = tile
	add_child(tile)


func check_adjacent_tiles(tile : Node2D, grid_position : Vector2) -> bool:
	
	# 2D array where second level hold same color (idx 0) and same shape (idx 1) properties
	var adjacent_tiles : Array = [ [null,null], [null,null], [null,null], [null,null] ]
	var adjacent_index : int = 0
	
	if grid_position.x > 0 and game_board[grid_position.x-1][grid_position.y] != null:
		
		if game_board[grid_position.x-1][grid_position.y].shape == tile.shape:
			print("tile in x-1,y pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x-1][grid_position.y].shape == tile.shape
		if game_board[grid_position.x-1][grid_position.y].color == tile.color:
			print("tile in x-1,y pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x-1][grid_position.y].color == tile.color
		adjacent_index += 1
	
	if grid_position.x < 11 and game_board[grid_position.x+1][grid_position.y] != null:

		if game_board[grid_position.x+1][grid_position.y].shape == tile.shape:
			print("tile in x+1,y pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x+1][grid_position.y].shape == tile.shape
		if game_board[grid_position.x+1][grid_position.y].color == tile.color:
			print("tile in x+1,y pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x+1][grid_position.y].color == tile.color
		adjacent_index += 1
		
	if grid_position.y > 0 and game_board[grid_position.x][grid_position.y-1] != null:

		if game_board[grid_position.x][grid_position.y-1].shape == tile.shape:
			print("tile in x,y-1 pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x][grid_position.y-1].shape == tile.shape
		if game_board[grid_position.x][grid_position.y-1].color == tile.color:
			print("tile in x,y-1 pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x][grid_position.y-1].color == tile.color
		adjacent_index += 1
		
	if grid_position.y < 7 and game_board[grid_position.x][grid_position.y+1] != null:

		if game_board[grid_position.x][grid_position.y+1].shape == tile.shape:
			print("tile in x,y+1 pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x][grid_position.y+1].shape == tile.shape
		if game_board[grid_position.x][grid_position.y+1].color == tile.color:
			print("tile in x,y+1 pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x][grid_position.y+1].color == tile.color
		adjacent_index += 1
		
	print ("CAT: adji="+str(adjacent_index)+" adjt="+str(adjacent_tiles))

	match adjacent_index:
		0:
			print("no neighbor case => FALSE")
			return false
		1:
			print("one neighbor case:")
			return (adjacent_tiles[0][0] or adjacent_tiles[0][1])
		2:
			print("two neighbors case:")
			return (adjacent_tiles[0][0] and adjacent_tiles[1][1]) or (adjacent_tiles[0][1] and adjacent_tiles[1][0])
		3:
			print("three neighbors case:")
			return ((adjacent_tiles[0][0] and adjacent_tiles[1][1] and adjacent_tiles[2][1]) or 
					(adjacent_tiles[1][0] and adjacent_tiles[0][1] and adjacent_tiles[2][1]) or 
					(adjacent_tiles[2][0] and adjacent_tiles[0][1] and adjacent_tiles[1][1]) or 
					(adjacent_tiles[0][1] and adjacent_tiles[1][0] and adjacent_tiles[2][0]) or 
					(adjacent_tiles[1][1] and adjacent_tiles[0][0] and adjacent_tiles[2][0]) or
					(adjacent_tiles[2][1] and adjacent_tiles[0][0] and adjacent_tiles[1][0]))
		4:
			print("four neighbors case:")
			return ((adjacent_tiles[0][0] and adjacent_tiles[1][0] and adjacent_tiles[2][1] and adjacent_tiles[3][1]) or
					(adjacent_tiles[0][0] and adjacent_tiles[1][1] and adjacent_tiles[2][0] and adjacent_tiles[3][1]) or
					(adjacent_tiles[0][0] and adjacent_tiles[1][1] and adjacent_tiles[2][1] and adjacent_tiles[3][0]) or
					(adjacent_tiles[0][1] and adjacent_tiles[1][1] and adjacent_tiles[2][0] and adjacent_tiles[3][0]) or
					(adjacent_tiles[0][1] and adjacent_tiles[1][0] and adjacent_tiles[2][1] and adjacent_tiles[3][0]) or
					(adjacent_tiles[0][1] and adjacent_tiles[1][0] and adjacent_tiles[2][0] and adjacent_tiles[3][1]))

	return false


func preview_next_tile(following_tile : Node2D) -> void:
	var tile : Node2D
	
	if (following_tile != null):
		preview_tile.emit(following_tile)
		tile = following_tile
	else:
		if (deck.size() > 0):
			tile = deck[0]

		else:
			pass #print("No more tile")
			# reset tile text or add an empty deck icon

	if (tile != null):
		preview_tile.emit(tile, avail_tile_colors[tile.color])



func update_score():
	pass


func game_over():
	pass


func save_highscore():
	pass


func load_highscores():
	pass
