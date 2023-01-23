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
@export var debug_enabled : bool

var avail_tile_shapes = [
	preload("res://Scenes/tileA.tscn"),
	preload("res://Scenes/tileB.tscn"),
	preload("res://Scenes/tileC.tscn"),
	preload("res://Scenes/tileD.tscn"),
	preload("res://Scenes/tileE.tscn"),
	preload("res://Scenes/tileF.tscn")
]

# last maybe not used at all
enum HIGHLIGHT_MODE { HIGHLIGHT_NONE, FIRST_AVAIL_MOVE, ALL_AVAIL_MOVE, RANDOM_MOVE, HIGHER_SCORE_MOVE }
var highlighted_cells : Array = []

signal deck_initialized
signal tile_picked
signal preview_tile
signal tile_placed
signal game_end
signal user_quit

var avail_tile_colors = { "color1" : Color(221,0,221,1), "color2" : Color(0,204,204,1), "color3" : Color(221,0,0,1), "color4" : Color(17,85,255,1), "color5" : Color(0,170,0,1), "color6" : Color(238,170,0,1)}

var tiles = []
var game_board : Array = []
var deck : Array = []
var next_tile : Node2D = null
var tile_score : int = 0
var avail_move : int = -1

# to remove soon
#var game_end : bool = false
var quit : bool = false

var TilesScore = [1, 2, 4, 8]
var FourWaysBonus = [25, 50, 100, 200, 400, 600, 800, 1000, 5000, 10000, 25000, 50000]
var FourWaysCount = 0
var player1Score = 0
var player2Score = 0

func _ready():
	OS.set_low_processor_usage_mode(true)
	randomize() #~no longer needed
	
	game_board = make_2d_array()
	
	load_highscores()
	
	init_deck()
	init_board()

func _process(_delta):
	#later: take_time_from_deck (no more tile => win)
	#	check_move_avail (false => gameover)
	#	update_score
	
	# with game_over signal => remove this check
	if (!quit): #!game_end and 
		if (next_tile == null):
			next_tile = preview_next_tile()
			debug("tile="+str(next_tile))

		if (next_tile == null):
			# game over, win
			print("no more tile: you WIN !!!")

		#WARNING, MUST be done once no for all iteration of _process func
		if (avail_move == -1):
			avail_move = check_available_move(HIGHLIGHT_MODE.HIGHLIGHT_NONE)
			debug("_process: AM="+str(avail_move))
			if (avail_move == 0):
				debug("_process: no more move available, GAME OVER")
				game_end.emit(false)
				quit = true #~just temp to exit main loop doing nothing
			
		var mpos : Vector2 = get_mouse_grid_position()
		##bad always work without delay/doing nothing when no click issued !

		if (next_tile != null):
			# check useless, to remove
			#debug ("tile ok, check")

			if (check_position_ok(mpos)):
				debug("position ok, proceed nt="+str(next_tile))

				# here loop: while tile not put on board, stay here
				if check_adjacent_tiles(next_tile, mpos) == true:
					add_tile(mpos, next_tile)
					pick_next_tile()
					next_tile = null
					avail_move = -1
					#useless update_score()

				else:
					##~gameover case TC
					debug("_process: invalid move")
					#game_end.emit(false)
		else:
			#will be done before, to move there
			debug("No more tile")
			#game_end = true
			game_end.emit(true)
			quit = true #~just temp to exit main loop doing nothing


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
		debug("MouseGblPos:" + str(mouseGblPos) + "  MouseGridPos:" + str(mouseGridPos))
		if is_in_grid(mouseGridPos):
			debug("uitp-> In grid:" + str(mouseGridPos))
			mpos = mouseGridPos
			return mpos

	return Vector2(-1,-1)


func init_deck():
	var tile : Node2D

	for shape in avail_tile_shapes:
		# there are two of the same tiles in the deck, range (1,3) to loop twice
		for i in range(1,3):
			for color in avail_tile_colors:
				tile = shape.instantiate()
				tile.modulate = avail_tile_colors[color]
				tile.color = color
				deck.append(tile)
			
	#print("Decktmp("+str(deck.size())+")=["+str(deck)+"]")
	deck.shuffle()
	debug("ID DecktmpS("+str(deck.size())+")=["+str(deck)+"]")
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
	while (shape_picked.size() < tile_shapes and color_picked.size() < tile_colors):

		current_tile = deck[deck_index]
		##deck_index += 1

		iteration_needed += 1

		debug("next tile (di="+str(deck_index)+") c=" + current_tile.color + " s=" + current_tile.shape)
		debug("colors picked="+str(color_picked))
		debug("shapes picked="+str(shape_picked))
		
		if (color_picked.has(current_tile.color)):
			debug("color : " + current_tile.color + " have already been picked, rejected")
			select_this_tile = false
		if (shape_picked.has(current_tile.shape)):
			debug("shape : " + current_tile.shape + " have already been picked, rejected")
			select_this_tile = false

		debug("tile selected="+str(select_this_tile))

		if (select_this_tile == true):
			debug("tile["+str(current_tile)+"] added to unique tiles set")
			unique_tiles_set.append(current_tile)
			
			deck.remove_at(deck_index)
			color_picked[current_tile.color] = 1
			shape_picked[current_tile.shape] = 1
		else:
			debug("tile["+str(current_tile)+"] NOT added to unique tiles set (di="+str(deck_index)+")")
			
			deck_index += 1
			current_tile = null
			select_this_tile = true

	debug("Iterations needed=" + str(iteration_needed))
	debug("IB BB=["+str(base_board)+"]")

	#TODO: beware if initial game_board does not contains all tiles or more (game variant)
	for filled_cell in base_board:
		game_board[filled_cell.x][filled_cell.y] = unique_tiles_set[tileIndex]
		tileIndex += 1
		game_board[filled_cell.x][filled_cell.y].position = grid_to_pixel(filled_cell.x, filled_cell.y)
		debug("put tile on:" + str(filled_cell))
		add_child(game_board[filled_cell.x][filled_cell.y])

	debug("IB GB=" + str(game_board))
	deck_initialized.emit(deck.size())


func check_position_ok(grid_position : Vector2) -> bool:
	#var there_is_a_move : bool = false
	#1. check cell is free
	#2. check tile follow the rules
	if (grid_position == Vector2(-1,-1)):
		##print("invalid cell")
		return false
	if game_board[grid_position.x][grid_position.y] == null:
		debug("CPOk: Cell["+str(grid_position)+"]:"+str(game_board[grid_position.x][grid_position.y]))
		return true
		#print ("check_position_ok: no more move available")
		#game_end.emit(false)
		#return false
	else:
		debug("Cell["+str(grid_position)+"] is occupied")
	
	return false


func check_available_move(highlight_mode : HIGHLIGHT_MODE) -> int:
	var avail_move : int = 0

	for column in range(0, board_width):
		for row in range(0, board_height):
			debug("CAM: check cell ["+str(column)+","+str(row)+"]")
			if (game_board[column][row] != null):
				debug("CAM: cell is already occupied, skip")
			elif check_adjacent_tiles(next_tile, Vector2(column, row)) == true:
				debug("CAM: Move found["+str(column)+","+str(row)+"]")
				if (highlight_mode == HIGHLIGHT_MODE.FIRST_AVAIL_MOVE):
					avail_move = 1
				elif (highlight_mode == HIGHLIGHT_MODE.ALL_AVAIL_MOVE or highlight_mode == HIGHLIGHT_MODE.RANDOM_MOVE):
					highlighted_cells.append(Vector2(column, row))
				elif (highlight_mode == HIGHLIGHT_MODE.HIGHLIGHT_NONE):
					avail_move += 1

	if (highlight_mode == HIGHLIGHT_MODE.RANDOM_MOVE):
		pass #pick one item from array

	if (highlight_mode != HIGHLIGHT_MODE.HIGHLIGHT_NONE):
		pass # actually lit the selected tiles

	return avail_move


func pick_next_tile() -> Node2D:
	var tile : Node2D = null
	
	if (deck.size() > 0):
		tile = deck.pop_front()
		debug("PiNT: (ds="+str(deck.size())+")  Tile=["+str(tile)+"]")
		tile_picked.emit()

	return tile


func add_tile(grid_position : Vector2, tile : Node2D) -> void:
	debug("AT: addtile called: pos=["+str(grid_position)+"] t=["+str(tile)+"]")
	tile.position = grid_to_pixel(grid_position.x, grid_position.y)
	game_board[grid_position.x][grid_position.y] = tile
	add_child(tile)
	update_score(tile_score)


#replace : bool => int (score) 0 or -1 as previous false
func check_adjacent_tiles(tile : Node2D, grid_position : Vector2) -> bool:
	
	# 2D array where second level hold same color (idx 0) and same shape (idx 1) properties
	var adjacent_tiles : Array = [ [null,null], [null,null], [null,null], [null,null] ]
	var adjacent_index : int = 0
	var allowed_move : bool = false
	
	if (tile == null or grid_position == null):
		return false

	if grid_position.x > 0 and game_board[grid_position.x-1][grid_position.y] != null:
		
		if game_board[grid_position.x-1][grid_position.y].shape == tile.shape:
			debug("tile in x-1,y pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x-1][grid_position.y].shape == tile.shape
		if game_board[grid_position.x-1][grid_position.y].color == tile.color:
			debug("tile in x-1,y pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x-1][grid_position.y].color == tile.color
		adjacent_index += 1
	
	if grid_position.x < 11 and game_board[grid_position.x+1][grid_position.y] != null:

		if game_board[grid_position.x+1][grid_position.y].shape == tile.shape:
			debug("tile in x+1,y pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x+1][grid_position.y].shape == tile.shape
		if game_board[grid_position.x+1][grid_position.y].color == tile.color:
			debug("tile in x+1,y pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x+1][grid_position.y].color == tile.color
		adjacent_index += 1
		
	if grid_position.y > 0 and game_board[grid_position.x][grid_position.y-1] != null:

		if game_board[grid_position.x][grid_position.y-1].shape == tile.shape:
			debug("tile in x,y-1 pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x][grid_position.y-1].shape == tile.shape
		if game_board[grid_position.x][grid_position.y-1].color == tile.color:
			debug("tile in x,y-1 pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x][grid_position.y-1].color == tile.color
		adjacent_index += 1
		
	if grid_position.y < 7 and game_board[grid_position.x][grid_position.y+1] != null:

		if game_board[grid_position.x][grid_position.y+1].shape == tile.shape:
			debug("tile in x,y+1 pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x][grid_position.y+1].shape == tile.shape
		if game_board[grid_position.x][grid_position.y+1].color == tile.color:
			debug("tile in x,y+1 pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x][grid_position.y+1].color == tile.color
		adjacent_index += 1
		
	debug("CAT: adji="+str(adjacent_index)+" adjt="+str(adjacent_tiles))

	# need a way to return nb adj tiles too
	# => replace bool by adjcent tiles, no need to use signal for this
	# 0 = false = no move
	match adjacent_index:
		0:
			debug("no neighbor case => FALSE")
			return false
		1:
			debug("one neighbor case")
			allowed_move = adjacent_tiles[0][0] or adjacent_tiles[0][1]
			if allowed_move == true:
				tile_placed.emit(1)
				return true
		2:
			debug("two neighbors case")
			allowed_move = (adjacent_tiles[0][0] and adjacent_tiles[1][1]) or (adjacent_tiles[0][1] and adjacent_tiles[1][0])
			if allowed_move == true:
				tile_placed.emit(2)
				return true
		3:
			debug("three neighbors case")
			allowed_move = ((adjacent_tiles[0][0] and adjacent_tiles[1][1] and adjacent_tiles[2][1]) or 
					(adjacent_tiles[1][0] and adjacent_tiles[0][1] and adjacent_tiles[2][1]) or 
					(adjacent_tiles[2][0] and adjacent_tiles[0][1] and adjacent_tiles[1][1]) or 
					(adjacent_tiles[0][1] and adjacent_tiles[1][0] and adjacent_tiles[2][0]) or 
					(adjacent_tiles[1][1] and adjacent_tiles[0][0] and adjacent_tiles[2][0]) or
					(adjacent_tiles[2][1] and adjacent_tiles[0][0] and adjacent_tiles[1][0]))
			if allowed_move == true:
				tile_placed.emit(3)
				return true
		4:
			debug("four neighbors case")
			allowed_move = ((adjacent_tiles[0][0] and adjacent_tiles[1][0] and adjacent_tiles[2][1] and adjacent_tiles[3][1]) or
					(adjacent_tiles[0][0] and adjacent_tiles[1][1] and adjacent_tiles[2][0] and adjacent_tiles[3][1]) or
					(adjacent_tiles[0][0] and adjacent_tiles[1][1] and adjacent_tiles[2][1] and adjacent_tiles[3][0]) or
					(adjacent_tiles[0][1] and adjacent_tiles[1][1] and adjacent_tiles[2][0] and adjacent_tiles[3][0]) or
					(adjacent_tiles[0][1] and adjacent_tiles[1][0] and adjacent_tiles[2][1] and adjacent_tiles[3][0]) or
					(adjacent_tiles[0][1] and adjacent_tiles[1][0] and adjacent_tiles[2][0] and adjacent_tiles[3][1]))
			if allowed_move == true:
				tile_placed.emit(4)
				return true

	return false


func preview_next_tile() -> Node2D:
	var tile : Node2D
	
	#if (following_tile != null):
	#	preview_tile.emit(following_tile, avail_tile_colors[following_tile.color])
	#	tile = following_tile
	if (deck.size() > 0):
		tile = deck[0]

		if (tile != null):
			preview_tile.emit(tile, avail_tile_colors[tile.color])
			return tile
		else:
			return null
	else:
		#print("No more tile") +~emit signal nomoretile
		return null  
		# reset tile text or add an empty deck icon


# ~not used
func update_score(score : int) -> void:
	player1Score += TilesScore[score - 1]
	if (score == 4):
		player1Score += FourWaysBonus[FourWaysCount]
		FourWaysCount += 1
	debug("Player1 score=" + str(player1Score) + "(4wc="+str(FourWaysCount)+")")


func highlight_cell(cell : Vector2) -> void:
	pass


# ~game_end signal => call this to do some work and ~display game over screen => fill name => highscore
func game_over():
	pass


func save_highscore():
	pass


func load_highscores():
	pass


func debug(msg : String) -> void:
	if (debug_enabled == true):
		print(msg)

func _on_tile_placed(score : int) -> void:
	debug("otp: score=" + str(score))
	tile_score = score
