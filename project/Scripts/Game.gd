extends Node2D

@export var base_board : PackedVector2Array
@export var board_width : int
@export var board_height : int
@export var x_start : int
@export var y_start : int
@export var tile_size : int
@export var player_name : String

# last maybe not used at all
enum HIGHLIGHT_MODE { HIGHLIGHT_NONE, FIRST_AVAIL_MOVE, ALL_AVAIL_MOVE, RANDOM_MOVE, HIGHER_SCORE_MOVE }
#var highlighted_cells : PackedVector2Array = []
var highlight_mode : int = HIGHLIGHT_MODE.HIGHLIGHT_NONE

signal tile_placed
signal game_end
signal user_quit
signal highlight_board_cell

var tiles = []
var game_board : Array = []
var next_tile : Node2D = null
#var tile_score : int = 0
var avail_move : int = -1

# to remove soon
#var game_end : bool = false
var quit : bool = false	#replace by end/use game_end back (more generic for all cases)

var TilesScore = [1, 2, 4, 8]
var FourWaysBonus = [25, 50, 100, 200, 400, 600, 800, 1000, 5000, 10000, 25000, 50000]

var current_player : int = 0
var playersScores : Array = [0, 0]
var fourWaysCounts : Array = [0, 0]

#use an array here for conveniency and easyness
@onready var Players_Panels = [ 
	$UI/HBoxContainer/Player1ScoreMargin/Player1_subPanel,
	$UI/HBoxContainer/Player2ScoreMargin/Player2_subPanel
]

@onready var DeckDisplay = null
var deck : Array

#TODO: add 2nd player (move turn + score upd)
#TODO: add tournament mode

func _init():
	print("main game: _init called")
	Global.debug_enabled = true


func _ready():
	OS.set_low_processor_usage_mode(true)
	randomize() #~no longer needed

	Global.debug("main game: _ready")
	
	#not needed
	DeckDisplay = find_child("DeckDisplay", true)
	Global.debug("main game: deck="+str(DeckDisplay))
	
	game_board = make_2d_array()
	
	load_highscores()

	init_board()


func _input(event):
	if event.is_action_pressed("Quit"):
		quit = true
	elif event.is_action_pressed("Return_To_Menu"):
		quit = true
		#emit signal when added
	elif event.is_action_pressed("Highlight_Mode"):
		Global.debug("previous enum value=" + str(highlight_mode))
		highlight_mode += 1
		highlight_mode %= HIGHLIGHT_MODE.size()
		Global.debug("previous enum value=" + str(highlight_mode))
		# update highlighted cells (just reemit signal ?? => not redo check avail move call)
		check_available_move(highlight_mode)


func _process(_delta):
	if quit:
		return

	if next_tile == null:
		next_tile = DeckDisplay.pick_next_tile()
			#here is the pb (maybe), game just init already pick next tile whereas one has already been picked
			# in deck
		Global.debug("next tile="+str(next_tile)+"  s="+next_tile.shape+"  c="+next_tile.color)
	
	if next_tile == null:
		Global.debug("No more tile, you Win !")
		game_over(true)
	else:
		if avail_move == -1:
			avail_move = check_available_move(highlight_mode)
			Global.debug("_process: AM="+str(avail_move))
		
		if (avail_move == 0):
			Global.debug("_process: no more move available, GAME OVER")
			game_over(false)
		else:
			var mpos : Vector2 = get_mouse_grid_position()

			if (check_position_ok(mpos)):
				Global.debug("position ok, proceed nt="+str(next_tile))
				
				var potential_tile_score = check_adjacent_tiles(next_tile, mpos)
				if potential_tile_score > 0:
					add_tile(mpos, next_tile)
					update_score(potential_tile_score)
					next_tile = null
					avail_move = -1
				else:
					Global.debug("_process: invalid move")
			else:
				pass
				##Global.debug("_process: invalid move")



#TODO rewrite logic to match new design
func _process_old(_delta):
	#later: take_tile_from_deck (no more tile => win)
	#	check_move_avail (false => gameover)

	# with game_over signal => remove this check
	if (!quit): #!game_end and 
		#if (next_tile == null):
		#	next_tile = DeckDisplay.preview_next_tile()
		#	Global.debug("tile="+str(next_tile))

		if (next_tile == null): # maybe not here, signal from DD => handle game end situations
			# game over, win
			print("no more tile: you WIN !!!")

		#WARNING, MUST be done once no for all iteration of _process func
		if (avail_move == -1):
			avail_move = check_available_move(highlight_mode)
			Global.debug("_process: AM="+str(avail_move))
			if (avail_move == 0):
				Global.debug("_process: no more move available, GAME OVER")
				#game_end.emit(false) #to where ? which node ?
				game_over(false)
				quit = true #~just temp to exit main loop doing nothing
			
		var mpos : Vector2 = get_mouse_grid_position()
		##bad always work without delay/doing nothing when no click issued !

		if (next_tile != null):
			# check useless, to remove
			#debug ("tile ok, check")

			if (check_position_ok(mpos)):
				Global.debug("position ok, proceed nt="+str(next_tile))

				# here loop: while tile not put on board, stay here
				var potential_tile_score = check_adjacent_tiles(next_tile, mpos)
				if potential_tile_score > 0:
					add_tile(mpos, next_tile)
					DeckDisplay.pick_next_tile()
					next_tile = null
					avail_move = -1
					update_score(potential_tile_score)

				else:
					##~gameover case TC
					Global.debug("_process: invalid move")
					#game_end.emit(false)
		else:
			#will be done before, to move there
			Global.debug("No more tile")
			#game_end = true
			# call gameover here which emit the signal to panel(s)
			#game_end.emit(true)
			game_over(true)
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
		Global.debug("MouseGblPos:" + str(mouseGblPos) + "  MouseGridPos:" + str(mouseGridPos))
		if is_in_grid(mouseGridPos):
			Global.debug("uitp-> In grid:" + str(mouseGridPos))
			mpos = mouseGridPos
			return mpos

	return mpos


func init_board():
	var tileIndex : int = 0
	var unique_tiles_set = DeckDisplay.get_unique_tiles_set()
	
	Global.debug("IB BB=["+str(base_board)+"]")

	#TODO: beware if initial game_board does not contains all tiles or more (game variant)
	for filled_cell in base_board:
		game_board[filled_cell.x][filled_cell.y] = unique_tiles_set[tileIndex]
		tileIndex += 1
		game_board[filled_cell.x][filled_cell.y].position = grid_to_pixel(filled_cell.x, filled_cell.y)
		Global.debug("put tile on:" + str(filled_cell))
		add_child(game_board[filled_cell.x][filled_cell.y])

	Global.debug("IB GB=" + str(game_board))


func check_position_ok(grid_position : Vector2) -> bool:
	if (grid_position == Vector2(-1,-1)):
		##print("invalid cell")
		return false
	if game_board[grid_position.x][grid_position.y] == null:
		Global.debug("CPOk: Cell["+str(grid_position)+"]:"+str(game_board[grid_position.x][grid_position.y]))
		return true
	else:
		Global.debug("Cell["+str(grid_position)+"] is occupied")
	
	return false


func check_available_move(selected_highlight_mode : HIGHLIGHT_MODE) -> int:
	var possible_moves : int = 0
	var cells : PackedVector2Array = cam_process_board()
	
	if (selected_highlight_mode == HIGHLIGHT_MODE.FIRST_AVAIL_MOVE):
		if cells.size() > 0:
			highlight_cell([cells[0]])
	elif (selected_highlight_mode == HIGHLIGHT_MODE.RANDOM_MOVE):
		for idx in randi_range(0, cells.size() - 1):
			highlight_cell([cells[idx]])
	elif (selected_highlight_mode == HIGHLIGHT_MODE.ALL_AVAIL_MOVE):
		#select n cells in array
		highlight_cell(cells)
	elif (selected_highlight_mode == HIGHLIGHT_MODE.HIGHLIGHT_NONE):
		pass

	possible_moves = cells.size()
	Global.debug("CAM: availmoves=" + str(possible_moves))

	return possible_moves


func cam_process_board() -> PackedVector2Array:
	var cells : PackedVector2Array = []
	
	for column in range(0, board_width):
		for row in range(0, board_height):
			Global.debug("CAMpb: check cell ["+str(column)+","+str(row)+"]")
			if (game_board[column][row] != null):
				Global.debug("CAMpb: cell is already occupied, skip")
			elif check_adjacent_tiles(next_tile, Vector2(column, row)) > 0:
				Global.debug("CAMpb: Move found["+str(column)+","+str(row)+"]")
				cells.append(Vector2(column, row))

	return cells


func add_tile(grid_position : Vector2, tile : Node2D) -> void:
	Global.debug("AT: addtile called: pos=["+str(grid_position)+"] t=["+str(tile)+"]")
	tile.position = grid_to_pixel(grid_position.x, grid_position.y)
	game_board[grid_position.x][grid_position.y] = tile
	add_child(tile)
	#update_score(tile_score)


#replace : bool => int (score) 0 or -1 as previous false
func check_adjacent_tiles(tile : Node2D, grid_position : Vector2) -> int:
	
	# 2D array where second level hold same color (idx 0) and same shape (idx 1) properties
	var adjacent_tiles : Array = [ [null,null], [null,null], [null,null], [null,null] ]
	var adjacent_index : int = 0
	var allowed_move : bool = false
	
	if (tile == null or grid_position == null):
		return 0

	if grid_position.x > 0 and game_board[grid_position.x-1][grid_position.y] != null:
		
		if game_board[grid_position.x-1][grid_position.y].shape == tile.shape:
			Global.debug("tile in x-1,y pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x-1][grid_position.y].shape == tile.shape
		if game_board[grid_position.x-1][grid_position.y].color == tile.color:
			Global.debug("tile in x-1,y pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x-1][grid_position.y].color == tile.color
		adjacent_index += 1
	
	if grid_position.x < 11 and game_board[grid_position.x+1][grid_position.y] != null:

		if game_board[grid_position.x+1][grid_position.y].shape == tile.shape:
			Global.debug("tile in x+1,y pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x+1][grid_position.y].shape == tile.shape
		if game_board[grid_position.x+1][grid_position.y].color == tile.color:
			Global.debug("tile in x+1,y pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x+1][grid_position.y].color == tile.color
		adjacent_index += 1
		
	if grid_position.y > 0 and game_board[grid_position.x][grid_position.y-1] != null:

		if game_board[grid_position.x][grid_position.y-1].shape == tile.shape:
			Global.debug("tile in x,y-1 pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x][grid_position.y-1].shape == tile.shape
		if game_board[grid_position.x][grid_position.y-1].color == tile.color:
			Global.debug("tile in x,y-1 pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x][grid_position.y-1].color == tile.color
		adjacent_index += 1
		
	if grid_position.y < 7 and game_board[grid_position.x][grid_position.y+1] != null:

		if game_board[grid_position.x][grid_position.y+1].shape == tile.shape:
			Global.debug("tile in x,y+1 pos has same shape")

		adjacent_tiles[adjacent_index][0] = game_board[grid_position.x][grid_position.y+1].shape == tile.shape
		if game_board[grid_position.x][grid_position.y+1].color == tile.color:
			Global.debug("tile in x,y+1 pos has same color")

		adjacent_tiles[adjacent_index][1] = game_board[grid_position.x][grid_position.y+1].color == tile.color
		adjacent_index += 1
		
	Global.debug("CAT: adji="+str(adjacent_index)+" adjt="+str(adjacent_tiles))

	match adjacent_index:
		0:
			Global.debug("no neighbor case => FALSE")
			return 0
		1:
			Global.debug("one neighbor case")
			allowed_move = adjacent_tiles[0][0] or adjacent_tiles[0][1]
			if allowed_move == true:
				return 1
		2:
			Global.debug("two neighbors case")
			allowed_move = (adjacent_tiles[0][0] and adjacent_tiles[1][1]) or (adjacent_tiles[0][1] and adjacent_tiles[1][0])
			if allowed_move == true:
				return 2
		3:
			Global.debug("three neighbors case")
			allowed_move = ((adjacent_tiles[0][0] and adjacent_tiles[1][1] and adjacent_tiles[2][1]) or 
					(adjacent_tiles[1][0] and adjacent_tiles[0][1] and adjacent_tiles[2][1]) or 
					(adjacent_tiles[2][0] and adjacent_tiles[0][1] and adjacent_tiles[1][1]) or 
					(adjacent_tiles[0][1] and adjacent_tiles[1][0] and adjacent_tiles[2][0]) or 
					(adjacent_tiles[1][1] and adjacent_tiles[0][0] and adjacent_tiles[2][0]) or
					(adjacent_tiles[2][1] and adjacent_tiles[0][0] and adjacent_tiles[1][0]))
			if allowed_move == true:
				return 3
		4:
			Global.debug("four neighbors case")
			allowed_move = ((adjacent_tiles[0][0] and adjacent_tiles[1][0] and adjacent_tiles[2][1] and adjacent_tiles[3][1]) or
					(adjacent_tiles[0][0] and adjacent_tiles[1][1] and adjacent_tiles[2][0] and adjacent_tiles[3][1]) or
					(adjacent_tiles[0][0] and adjacent_tiles[1][1] and adjacent_tiles[2][1] and adjacent_tiles[3][0]) or
					(adjacent_tiles[0][1] and adjacent_tiles[1][1] and adjacent_tiles[2][0] and adjacent_tiles[3][0]) or
					(adjacent_tiles[0][1] and adjacent_tiles[1][0] and adjacent_tiles[2][1] and adjacent_tiles[3][0]) or
					(adjacent_tiles[0][1] and adjacent_tiles[1][0] and adjacent_tiles[2][0] and adjacent_tiles[3][1]))
			if allowed_move == true:
				return 4

	return 0


func update_score(score : int) -> void:
	playersScores[current_player] += TilesScore[score - 1]
	if (score == 4):
		playersScores[current_player] += FourWaysBonus[fourWaysCounts[current_player]]
		fourWaysCounts[current_player] += 1
		#update_p1_fourways.emit(fourWaysCounts[current_player])
		Players_Panels[current_player].update_player_fways_counter(fourWaysCounts[current_player])
	#update_p1_score.emit(playersScores[current_player])
	Players_Panels[current_player].update_player_score(playersScores[current_player])
	Global.debug("US: Player1 score=" + str(playersScores[current_player]) + "(4wc="+str(fourWaysCounts[current_player])+")")


func highlight_cell(cells : Array) -> void:
	# draw lines around cell then animate with colors cycle (tweens ?)
	var coordinates_array = []
	for cell in cells:
		var Apoint = grid_to_pixel(cell.x, cell.y)
		var Bpoint = Vector2(Apoint.x + 64, Apoint.y)
		var Cpoint = Vector2(Apoint.x + 64, Apoint.y + 64)
		var Dpoint = Vector2(Apoint.x, Apoint.y + 64)
		var Epoint = Vector2(Apoint.x, Apoint.y)
		coordinates_array.append([Apoint, Bpoint, Cpoint, Dpoint, Epoint])
	#var Color ?
	#anim/cycle
	
	highlight_board_cell.emit(coordinates_array)


# ~game_end signal => call this to do some work and ~display game over screen => fill name => highscore
func game_over(win : bool):
	# for all panel (so many ? just this one yet), fade background/blurr using overlay
	#=> load game over panel
	##get_tree().get_child("GameOverPanel").visible = true #doesn't work (~func not called at all!)
	quit = true
	if win == true:
		Global.debug("Game won")
	else:
		Global.debug("Game loss")
	game_end.emit(win)


func save_highscore():
	pass


func load_highscores():
	pass


## bad way to get it
func _on_deck_display_deck_initialized(deck_initialized : Array) -> void:
	deck = deck_initialized
	Global.debug("Signal deck initialized received")


func _on_deck_display_deck_empty():
	Global.debug("Deck empty sig received")
	game_over(true)
