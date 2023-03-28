extends Control

#add pages count, like help prev/next or click = next then close
@export var scoreItemScene : PackedScene = preload("res://Scenes/HighScores/ScoreItem.tscn")

var currentPageIdx : int = 0
var allPages : Array = []
var NodesStore : Array = []

signal button_clicked(buttonID : int) #?

func _ready():
	Global.debug_enabled = true #tmp
	
	allPages.resize(Global.highScores.size())
	NodesStore.resize(Global.highScores.size())
	Global.debug("HS size="+str(Global.highScores.size()))
	
	
	#read global highscores table
	Global.load_high_scores()
	for key in Global.highScores:
		Global.debug("HS("+key+")="+str(Global.highScores[key]))
		allPages[currentPageIdx] = key
		NodesStore[currentPageIdx] = []
		NodesStore[currentPageIdx].resize(10)
		currentPageIdx += 1
	currentPageIdx = 0

	update_page(currentPageIdx)

func update_page(pageIdx : int) -> void:
	var node
	var currentPage : String

	currentPage = allPages[pageIdx]
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/GameType.text = allPages[pageIdx]

	#keep track of node to free them/cache them, not always instantiate new nodes !
	for idx in range(0,10):
		if NodesStore[pageIdx][idx] == null:
			node = scoreItemScene.instantiate()
			node.init(idx+1, Global.highScores[currentPage][idx][Global.HIGHSCORES_NAME_IDX],
			Global.highScores[currentPage][idx][Global.HIGHSCORES_SCORE_IDX],
			Global.highScores[currentPage][idx][Global.HIGHSCORES_FOURWAYS_IDX],
			Global.highScores[currentPage][idx][Global.HIGHSCORES_TILESREMAINING_IDX])
			node.add_to_group(currentPage, false)
		else:
			node = NodesStore[pageIdx][idx]

		$"CenterContainer/VBoxContainer/HighScores-Items".add_child(node)
		NodesStore[pageIdx][idx] = node


func _on_texture_button_pressed():
	hide()


func _on_previous_button_pressed():
	if currentPageIdx > 0:
		currentPageIdx -= 1
	Global.debug("cp="+str(currentPageIdx))
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/GameType.text = allPages[currentPageIdx]

	Global.debug("remove nodes from group="+allPages[currentPageIdx + 1])
	for node in get_tree().get_nodes_in_group(allPages[currentPageIdx + 1]):
		$"CenterContainer/VBoxContainer/HighScores-Items".remove_child(node)
	#get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, allPages[currentPageIdx + 1], "$CenterContainer/VBoxContainer/HighScores-Items.remove_child")
	update_page(currentPageIdx)


func _on_next_button_pressed():
	if currentPageIdx < Global.highScores.size() - 1:
		currentPageIdx += 1
	Global.debug("cp="+str(currentPageIdx))
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/GameType.text = allPages[currentPageIdx]

	Global.debug("remove nodes from group="+allPages[currentPageIdx - 1])
	for node in get_tree().get_nodes_in_group(allPages[currentPageIdx - 1]):
		$"CenterContainer/VBoxContainer/HighScores-Items".remove_child(node)
	#get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, allPages[currentPageIdx - 1], "$CenterContainer/VBoxContainer/HighScores-Items.remove_child")
	update_page(currentPageIdx)
