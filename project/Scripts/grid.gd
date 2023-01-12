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
	#preload("res://Scenes/tileE1.tscn"),
	#preload("res://Scenes/tileF1.tscn")
]

#tmp
#var avail_tile_shapes = ["A", "B", "C", "D", "E", "F"]
#var avail_tile_colors = ["1", "2", "3", "4", "5", "6"]
var avail_tile_colors = { "color1" : Color(221,0,221,1), "color2" : Color(0,204,204,1), "color3" : Color(221,0,0,1), "color4" : Color(17,85,255,1), "color5" : Color(0,170,0,1), "color6" : Color(238,170,0,1)}

var FourWaysBonus = [25, 50, 100, 200, 400, 600, 800, 1000, 5000, 10000, 25000, 50000]

var tiles = []
var game_board : Array = []
var deck : Array = []

var game_end : bool = false
var quit : bool = false
var tile_picked = false

func _ready():
	randomize()
	game_board = make_2d_array()
	
	load_highscores()
	
	#init_deck_tmp()
	init_deck()
	init_board()

func _process(_delta):
	#later: take_time_from_deck (no more tile => win)
	#	check_move_avail (false => gameover)
	#	update_score
	if (!game_end and !quit):
		if !tile_picked:
			preview_next_tile()
			tile_picked = true
		var mpos : Vector2 = get_mouse_grid_position()
		##bad always work without delay/doing nothing when no click issued !
		if (check_position_ok(mpos)):
			print("position ok")
			var next_tile = pick_next_tile()
			if (next_tile != null):
				if check_adjacent_tiles(next_tile, mpos) == true:
					add_tile(mpos, next_tile)
					update_score()
					tile_picked = false
				else:
					print ("Tile cannot be put in that cell")
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
	# released event not needed
	#if Input.is_action_just_released("ui_touch"):
	#	if is_in_grid(mouseGridPos): ## && controlling:
#			print ("uitr-> In grid:" + str(mouseGridPos))
	return Vector2(-1,-1)


func init_deck():
	var tile : Node2D
	for shape in avail_tile_shapes:
		for i in range(1,3):
			for color in avail_tile_colors:
				tile = shape.instantiate()
				tile.modulate = avail_tile_colors[color]
				tile.color = color
				deck.append(tile)
			
	#print("Decktmp("+str(deck.size())+")=["+str(deck)+"]")
	deck.shuffle()
	print("DecktmpS("+str(deck.size())+")=["+str(deck)+"]")
	
#func init_deck_tmp():
#	var deck = []
#	for shape in avail_tile_shapes:
#		for color in avail_tile_colors:
#			deck.append([shape, color])
#			deck.append([shape, color])
#
#	print("Decktmp("+str(deck.size())+")=["+str(deck)+"]")
#
#	deck.shuffle()
#	print("DecktmpS("+str(deck.size())+")=["+str(deck)+"]")

func init_board():
	print("BB=["+str(base_board)+"]")
	for filled_cell in base_board:
		var next_tile = pick_next_tile()
		if (next_tile != null):
			game_board[filled_cell.x][filled_cell.y] = next_tile
			next_tile.position = grid_to_pixel(filled_cell.x, filled_cell.y)
			print("put tile on:" + str(filled_cell))
			add_child(next_tile)

	#init board from base board array
#	game_board[0][0] = available_tiles[0].instantiate()
#	game_board[0][0].position = grid_to_pixel(0,0)
#	game_board[0][0].modulate = Color(255,0,0,1)
#	add_child(game_board[0][0])
#
#	game_board[11][0] = available_tiles[1].instantiate()
#	game_board[11][0].position = grid_to_pixel(11,0)
#	game_board[11][0].modulate = Color(0,255,0,1)
#	add_child(game_board[11][0])
#
#	game_board[0][7] = available_tiles[2].instantiate()
#	game_board[0][7].position = grid_to_pixel(0,7)
#	game_board[0][7].modulate = Color(0,0,255,1)
#	add_child(game_board[0][7])
#
	print("GB=" + str(game_board))

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
	var tile : Node2D = deck.pop_front()
	print("(ds="+str(deck.size())+")Tile=["+str(tile)+"]")
	return tile

func add_tile(grid_position : Vector2, tile : Node2D) -> void:
	print("addtile called: pos=["+str(grid_position)+"]")
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
		if game_board[grid_position.x-1][grid_position.y].color == tile.color:
			print("tile in x-1,y pos has same color")
	if grid_position.x < 11 and game_board[grid_position.x+1][grid_position.y] != null:
		number_of_neighbor += 1
		if game_board[grid_position.x+1][grid_position.y].shape == tile.shape:
			print("tile in x+1,y pos has same shape")
		if game_board[grid_position.x+1][grid_position.y].color == tile.color:
			print("tile in x+1,y pos has same color")
	if grid_position.y > 0 and game_board[grid_position.x][grid_position.y-1] != null:
		number_of_neighbor += 1
		if game_board[grid_position.x][grid_position.y-1].shape == tile.shape:
			print("tile in x,y-1 pos has same shape")
		if game_board[grid_position.x][grid_position.y-1].color == tile.color:
			print("tile in x,y-1 pos has same color")
	if grid_position.y < 7 and game_board[grid_position.x][grid_position.y+1] != null:
		number_of_neighbor += 1
		if game_board[grid_position.x][grid_position.y+1].shape == tile.shape:
			print("tile in x,y+1 pos has same shape")
		if game_board[grid_position.x][grid_position.y+1].color == tile.color:
			print("tile in x,y+1 pos has same color")
	print ("NB="+str(number_of_neighbor))
	
	if (number_of_neighbor == 0):
		return false
	return true

func preview_next_tile():
	var tile : Node2D
	if (deck.size() > 0):
		tile = deck[0]
		print("(ds="+str(deck.size())+")Tile=["+str(tile)+"] c="+tile.color+" s="+tile.shape)
		##$UI/VBoxContainer/MarginContainer/NextTileDisplay.texture = tile.get_child(0).texture
		var NextTileDisplay = get_tree().get_root().get_node("Game").get_node("UI").get_node("VBoxContainer").get_node("MarginContainer").get_node("NextTileDisplay")
		NextTileDisplay.texture = tile.get_node("Sprite2D").texture
		NextTileDisplay.modulate = avail_tile_colors[tile.color]
		print("decktext=" + str(NextTileDisplay.texture)) #/VBoxContainer/MarginContainer/NextTileDisplay
		# ~signal NTD node from grid with text ref/color/shape and UI component just read tex and display it
		
	else:
		pass
	return tile

func update_score():
	pass

func game_over():
	pass

func save_highscore():
	pass
	
func load_highscores():
	pass
