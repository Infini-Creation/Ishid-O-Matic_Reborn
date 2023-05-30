extends Node2D

@export var base_board : PackedVector2Array
@export var board_width : int
@export var board_height : int
@export var x_start : int
@export var y_start : int
@export var tile_size : int

@export var gameType : String
@export var numberOfPlayers : int

var highlight_mode : int = Global.HIGHLIGHT_MODE.HIGHLIGHT_NONE

signal game_end(status : int, playerIdx: int, score: Array, fourways : Array, tilesRem : int)
#signal game_is_over
#signal user_quit
signal highlight_board_cell
signal playsound(String)

var tiles = []
var game_board : Array = []
var next_tile : Node2D = null
#var tile_score : int = 0
var avail_move : int = -1
var tournamentSeed : int

# to remove soon
#var game_end : bool = false
var quit : bool = false	#replace by end/use game_end back (more generic for all cases)

const TilesScore = [1, 2, 4, 8]
const FourWaysBonus = [25, 50, 100, 200, 400, 600, 800, 1000, 5000, 10000, 25000, 50000]
const TilesRemainingBonus = {2: 100, 1: 500, 0: 1000}
const ScoreMultiplier = 2

const TileOffset = 32

var current_player : int = 0
var playersScores : Array = [0, 0]
var fourWaysCounts : Array = [0, 0]
var currentScoreMultiplier = 1

#tmpdebug
var fakeFourWays : bool = false

#use an array here for conveniency and easyness
@onready var Players_Panels = [ 
	$UI/HBoxContainer/Player1ScoreMargin/Player_subPanel,
	$UI/HBoxContainer/Player2ScoreMargin/Player_subPanel
]

@onready var DeckDisplay = null
var deck : Array  #unused, to remove

@onready var gameLossPanel = $GameOverPanel
@onready var gameWinPanel = $GameWinPanel
@onready var gameQuitPanel = $GameQuitPanel

var game_end_status : int = -1

#TODO: add 2nd player (move turn + score upd)
#TODO: add tournament mode (LATER)

func _init():
	Global.debug("main game: _init called")
	quit = false
	# other vars ?
	

func _ready():
	OS.set_low_processor_usage_mode(true)
	#randomize() #~no longer needed, "automatically called when the project is run"

	Global.debug("main game: _ready")
	
	#not needed ?
	DeckDisplay = find_child("DeckDisplay", true)
	Global.debug("main game: deck="+str(DeckDisplay))
	
	game_board = make_2d_array()

	if gameType == Global.GAMETYPE_TOURNAMENT:
		#too early here, signal from panel handled AFTER !!
		
		if Global.continue_tournament == true:
			tournamentSeed = Global.load_seed()
			Global.debug("conttour: saved seed= "+str(tournamentSeed))
		else:
			tournamentSeed = int(Time.get_unix_time_from_system ())
			Global.debug("newtour: saved seed= "+str(tournamentSeed))
			Global.save_seed(tournamentSeed)

		$"UI/HBoxContainer/MiddleContainer/Tournament-Label".text = "Tournament seed="+str(tournamentSeed)
		$"UI/HBoxContainer/MiddleContainer/Tournament-Label".show()
		
		# display tournament pop-up : start a new one or continue current
		# 1=gen new seed & save, 2=load seed
		seed(tournamentSeed)
		DeckDisplay.init_deck()
		#display tournament label (later texture maybe)

	init_board()
	DeckDisplay.deck_is_ready() #not even needed! (process pnt)

	highlight_mode = Global.settings["hints"]
	if highlight_mode < 0 or highlight_mode > Global.HIGHLIGHT_MODE.size():
		highlight_mode = 0

	if gameType == Global.GAMETYPE_TWOPLAYERS:
		Players_Panels[current_player].highlight_current_player(1.0)


func _input(event):
	if event.is_action_pressed("Quit"):
		quit = true
	elif event.is_action_pressed("Return_To_Menu"):
		quit = true
		#emit signal when added
	elif event.is_action_pressed("Highlight_Mode"):
		Global.debug("previous enum value=" + str(highlight_mode))
		highlight_mode += 1
		highlight_mode %= Global.HIGHLIGHT_MODE.size()
		Global.debug("previous enum value=" + str(highlight_mode))
		# update highlighted cells (just reemit signal ?? => not redo check avail move call)
		check_available_move(highlight_mode)
	elif event.is_action_pressed("FourWaysDebug"):
		Global.debug("fake four ways event")
		fakeFourWays = true
	elif event.is_action_pressed("gameoverlossDebug"):
		Global.debug("fake game over LOSS")
		game_over(Global.GAME_EXIT_STATUS.GAME_LOSS)
	elif event.is_action_pressed("gameoverwinDebug"):
		Global.debug("fake game over WIN")
		game_over(Global.GAME_EXIT_STATUS.GAME_WON)


func _process(_delta):
	if quit:
		game_over(Global.GAME_EXIT_STATUS.USER_QUIT) # add another param win/loss/exit
		return

	if game_end_status >= 0:
		Global.debug("_p GES="+str(game_end_status))
		return

	if next_tile == null:
		next_tile = DeckDisplay.pick_next_tile()
			#here is the pb (maybe), game just init already pick next tile whereas one has already been picked
			# in deck
		Global.debug("next tile="+str(next_tile))
	
	if next_tile == null:
		Global.debug("No more tile, you Win !")
		game_over(Global.GAME_EXIT_STATUS.GAME_WON)
	else:
		#Global.debug("next tile s="+next_tile.shape+"  c="+next_tile.color)
		if avail_move == -1:
			avail_move = check_available_move(highlight_mode)
			Global.debug("_process: AM="+str(avail_move))
			DeckDisplay.update_available_moves_counter(avail_move)
		
		if (avail_move == 0):
			Global.debug("_process: no more move available, GAME OVER")
			game_over(Global.GAME_EXIT_STATUS.GAME_LOSS)
		else:
			var mpos : Vector2 = get_mouse_grid_position()

			if (check_position_ok(mpos)):
				Global.debug("position ok, proceed nt="+str(next_tile))
				
				var potential_tile_score = check_adjacent_tiles(next_tile, mpos)
				if potential_tile_score > 0: ## true: ##tmp test 
					add_tile(mpos, next_tile)
					playsound.emit("tile")
					if potential_tile_score == 4 or fakeFourWays == true:
						play_fourWays_effects(mpos)
						playsound.emit("fourways")
						fakeFourWays = false
					##DeckDisplay.update()
					update_score(potential_tile_score)
					next_tile = null
					avail_move = -1

					if gameType == Global.GAMETYPE_ONEPLAYER:
						pass
					elif gameType == Global.GAMETYPE_TWOPLAYERS:
						Players_Panels[current_player].stop_highlight_current_player()
						current_player = (current_player + 1) % 2
						Players_Panels[current_player].highlight_current_player(1.0)
					elif gameType == Global.GAMETYPE_TOURNAMENT:
						pass
					elif gameType == Global.GAMETYPE_ENHANCED:
						pass
				else:
					Global.debug("_process: invalid move")
			else:
				pass
				##Global.debug("_process: invalid move")


# gameType: enum later
func setup(number_of_players : int, game_type: String) -> void:
	Global.debug("setup called gt => " + game_type + "  nbp="+str(number_of_players))
	gameType = game_type
	numberOfPlayers = number_of_players


func make_2d_array():
	var array = []
	for i in board_width:
		array.append([])
		for j in board_height:
			array[i].append(null)
	return array


func grid_to_pixel(column, row):
	var new_x = x_start + TileOffset + column * tile_size
	var new_y = y_start + TileOffset + row * tile_size
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
		Global.debug("IB: tile="+str(unique_tiles_set[tileIndex])+" parent="+str(unique_tiles_set[tileIndex].get_parent())+" owner="+str(unique_tiles_set[tileIndex].owner))
		
		game_board[filled_cell.x][filled_cell.y].position = grid_to_pixel(filled_cell.x, filled_cell.y)
		Global.debug("IB: put tile on:" + str(filled_cell))
		
		if unique_tiles_set[tileIndex].get_parent() != null:
			Global.debug("IB: tile has a parent, remove it")
			unique_tiles_set[tileIndex].get_parent().remove_child(unique_tiles_set[tileIndex])
			Global.debug("IB:parent="+str(unique_tiles_set[tileIndex].get_parent())+" owner="+str(unique_tiles_set[tileIndex].owner))
		add_child(game_board[filled_cell.x][filled_cell.y])
		
		tileIndex += 1
	Global.debug("IB GB=" + str(game_board))


func check_position_ok(grid_position : Vector2) -> bool:
	if (grid_position == Vector2(-1,-1)):
		return false
	if game_board[grid_position.x][grid_position.y] == null:
		Global.debug("CPOk: Cell["+str(grid_position)+"]:"+str(game_board[grid_position.x][grid_position.y]))
		return true
	else:
		Global.debug("Cell["+str(grid_position)+"] is occupied")
	
	return false


func check_available_move(selected_highlight_mode : Global.HIGHLIGHT_MODE) -> int:
	var possible_moves : int = 0
	var cells : PackedVector2Array = cam_process_board(next_tile)
	
	if (selected_highlight_mode == Global.HIGHLIGHT_MODE.FIRST_AVAIL_MOVE):
		if cells.size() > 0:
			highlight_cell([cells[0]])
	elif (selected_highlight_mode == Global.HIGHLIGHT_MODE.RANDOM_MOVE):
		for idx in randi_range(0, cells.size() - 1):
			highlight_cell([cells[idx]])
	elif (selected_highlight_mode == Global.HIGHLIGHT_MODE.ALL_AVAIL_MOVE):
		#select n cells in array
		highlight_cell(cells)
	elif (selected_highlight_mode == Global.HIGHLIGHT_MODE.HIGHLIGHT_NONE):
		#need to clear overlay one time
		highlight_cell([])
		#pass

	possible_moves = cells.size()
	Global.debug("CAM: availmoves=" + str(possible_moves))

	return possible_moves


# remove use of global var !
func cam_process_board(tile : Node2D) -> PackedVector2Array:
	var cells : PackedVector2Array = []
	
	for column in range(0, board_width):
		for row in range(0, board_height):
			Global.debug("CAMpb: check cell ["+str(column)+","+str(row)+"]")
			if (game_board[column][row] != null):
				Global.debug("CAMpb: cell is already occupied, skip")
			elif check_adjacent_tiles(tile, Vector2(column, row)) > 0:
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
	playersScores[current_player] += TilesScore[score - 1] * currentScoreMultiplier
	if (score == 4):
		playersScores[current_player] += FourWaysBonus[fourWaysCounts[current_player]]
		currentScoreMultiplier *= ScoreMultiplier
		fourWaysCounts[current_player] += 1
		#update_p1_fourways.emit(fourWaysCounts[current_player])
		Players_Panels[current_player].update_player_fways_counter(fourWaysCounts[current_player])
	#update_p1_score.emit(playersScores[current_player])
	Players_Panels[current_player].update_player_score(playersScores[current_player])
	Global.debug("US: Player1 score=" + str(playersScores[current_player]) + "(4wc="+str(fourWaysCounts[current_player])+")")


func highlight_cell(cells : Array) -> void:
	var coordinates_array = []
	for cell in cells:
		var Apoint = grid_to_pixel(cell.x, cell.y) - Vector2(TileOffset, TileOffset)
		var Bpoint = Vector2(Apoint.x + 64, Apoint.y)
		var Cpoint = Vector2(Apoint.x + 64, Apoint.y + 64)
		var Dpoint = Vector2(Apoint.x, Apoint.y + 64)
		var Epoint = Vector2(Apoint.x, Apoint.y)
		
		coordinates_array.append([Apoint, Bpoint, Cpoint, Dpoint, Epoint])

	highlight_board_cell.emit(coordinates_array)


func play_fourWays_effects(gridpos : Vector2):
	#Global.debug("4W effect on: "+str(gridpos))

	var tilesAnim = self.create_tween().set_parallel(true) #= no anim at all
	tilesAnim.set_loops(2)

	for neighbor in [Vector2(0,0), Vector2(-1,0), Vector2(1,0), Vector2(0,-1), Vector2(0,1)]:
		tilesAnim.parallel().tween_property(game_board[gridpos.x + neighbor.x][gridpos.y + neighbor.y], "scale", Vector2(0.75,0.75), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tilesAnim.parallel().tween_property(game_board[gridpos.x + neighbor.x][gridpos.y + neighbor.y], "rotation", PI, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tilesAnim.chain().tween_interval(0.25)

	for neighbor in [Vector2(0,0), Vector2(-1,0), Vector2(1,0), Vector2(0,-1), Vector2(0,1)]:
		tilesAnim.parallel().tween_property(game_board[gridpos.x + neighbor.x][gridpos.y + neighbor.y], "scale", Vector2(1,1), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tilesAnim.parallel().tween_property(game_board[gridpos.x + neighbor.x][gridpos.y + neighbor.y], "rotation", -PI, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	for neighbor in [Vector2(0,0), Vector2(-1,0), Vector2(1,0), Vector2(0,-1), Vector2(0,1)]:
		tilesAnim.parallel().tween_property(game_board[gridpos.x + neighbor.x][gridpos.y + neighbor.y], "rotation", 0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tilesAnim.play()

# ~game_end signal => call this to do some work and ~display game over screen => fill name => highscore
func game_over(status : int):
	# for all panel (so many ? just this one yet), fade background/blurr using overlay
	#=> load game over panel
	##get_tree().get_child("GameOverPanel").visible = true #doesn't work (~func not called at all!)
	##quit = true #no longer needed
	game_end_status = status
	#var win : bool = false
	Global.debug("ges="+str(game_end_status))
	#better to let status to signal receiver to deal with it directly, useless here
#	if status == GAME_EXIT_STATUS.GAME_WON:
#		Global.debug("Game won")
#		win = true
	var tilesRemaining = DeckDisplay.get_deck_count()
	Global.debug("remtiles="+str(tilesRemaining)+"  ps="+str(playersScores[current_player]))
	if tilesRemaining <= TilesRemainingBonus.size() and TilesRemainingBonus.has(tilesRemaining):
		playersScores[current_player] += TilesRemainingBonus[tilesRemaining]
	Global.debug("finalscore="+str(playersScores[current_player]))
	
	if status == Global.GAME_EXIT_STATUS.GAME_LOSS:
		Global.debug("game:Game loss")
		playsound.emit("loss")
		#emit sig game loss to origin
		# or gameend(loss)
		
		#game_is_over.emit()
		gameLossPanel.show()
			#or use signal to panel directly (benefit?)
	elif status == Global.GAME_EXIT_STATUS.GAME_WON:
		Global.debug("game:Game Won")
		playsound.emit("win")
		#as loss, emit sig to origin on win
		
		#add final bonus(es)
		gameWinPanel.show()
	elif status == Global.GAME_EXIT_STATUS.USER_QUIT:
		Global.debug("game quit")
		
		gameQuitPanel.show()
		# go back to main menu or just exit
		#Global.debug("emit game_end signal")
		#game_end.emit(game_end_status, current_player, [], [], 0)
	#show panel => signal => action (return to origin scene) see below
	##game_end.emit(status, current_player, playersScores[current_player], fourWaysCounts[current_player], DeckDisplay.get_deck_count())


# do the same for game win panel
func _on_game_over_panel_is_closed():
	Global.debug("GOP closed, emit game_end signal")
	game_end.emit(game_end_status, current_player, playersScores, fourWaysCounts, DeckDisplay.get_deck_count())
	
## bad way to get it
func _on_deck_display_deck_initialized(deck_initialized : Array) -> void:
	deck = deck_initialized
	Global.debug("Signal deck initialized received")


# may be useless now
func _on_deck_display_deck_empty():
	Global.debug("Deck empty sig received, win")
	##game_over(true) #should be STATUS_WIN but here may be redundant, 
	#check _process for already managed case


func _on_game_win_panel_is_closed():
	Global.debug("GOPw closed, emit game_end signal")
	game_end.emit(game_end_status, current_player, playersScores, fourWaysCounts, DeckDisplay.get_deck_count())


func _on_game_quit_panel_quit(confirm : bool):
	Global.debug("Quit Confirm panel closed: "+str(confirm))
	if confirm == true:
		Global.debug("Quit to main menu")
		game_end.emit(Global.GAME_EXIT_STATUS.USER_QUIT, current_player, playersScores, fourWaysCounts, DeckDisplay.get_deck_count())
		gameQuitPanel.hide()
	else:
		Global.debug("keep playing")
		gameQuitPanel.hide()
		
		# reset game quit setting
		quit = false
		game_end_status = -1
