extends Control

@export var scoreItemScene : PackedScene = preload("res://Scenes/HighScores/ScoreItem.tscn")

const GameTypeTranslationKeys : Dictionary = {
	"OnePlayer" : "HIGHSCORES1P",
	"TwoPlayers" : "HIGHSCORES2P",
	"Tournament": "HIGHSCORESTOUR",
	"Enhanced": "HIGHSCORESENH"
}

var currentPageIdx : int = 0
var allPages : Array = []
var NodesStore : Array = []

#signal button_clicked(buttonID : int) #?

func _ready():
	# not on ready but when panel is set to visible
	allPages.resize(Global.highScores.size())
	NodesStore.resize(Global.highScores.size())
	Global.debug("HS size="+str(Global.highScores.size()))
	
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
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/GameType.text = GameTypeTranslationKeys[allPages[pageIdx]]
			#here TR key

	#keep track of node to free them/cache them, not always instantiate new nodes !
	for idx in range(0,10):
		if NodesStore[pageIdx][idx] == null:
			node = scoreItemScene.instantiate()
			#not a very good "fix"
			if Global.highScores[currentPage] != null and Global.highScores[currentPage].size() > 0:
				node.init(idx+1, Global.highScores[currentPage][idx][Global.HIGHSCORES_NAME_IDX],
				Global.highScores[currentPage][idx][Global.HIGHSCORES_SCORE_IDX],
				Global.highScores[currentPage][idx][Global.HIGHSCORES_FOURWAYS_IDX],
				Global.highScores[currentPage][idx][Global.HIGHSCORES_TILESREMAINING_IDX])
				node.add_to_group(currentPage, false)
		else:
			node = NodesStore[pageIdx][idx]

		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		$"CenterContainer/VBoxContainer/HighScores-Items".add_child(node)
		NodesStore[pageIdx][idx] = node


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


#func add_new_highscore(gameType: int, pName: String, score: int, fourWays : int, tilesRemaining: int):
#	pass
	# 1st display right HS page according to gametype
	# with help of tween
	# put below row one row down
	# add new row


func _on_close_pressed():
	hide()
