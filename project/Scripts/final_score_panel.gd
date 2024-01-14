extends Control

@export var frameSkip : int	#what the purpose ?
@export var numberOfPlayers : int

signal is_closed

var score : int = 0
var baseScore : int = 0
var fourWays : int = 0
var tilesRemaining : int = 0

var prevScore : int = 0
var initialized : bool = false
var frameCount : int = 0
var scoresProcessed : Array = [false, false]
var currentScoreIndex : int = 0

# should be array, as in game, for both players
# anim P1, then P2
func setup(base_score : int, four_ways : int, tiles_remaining : int) -> void:
	baseScore = base_score
	fourWays = four_ways
	tilesRemaining = tiles_remaining
	initialized = true

# going from 0 to score 1, add 4ways bonus, add rem tiles bonus
# with sounds & maybe shaking
func _ready():
	#to remove
	Global.debug("final score panel ready")


func _process(delta : float):
	# process each player one after another
	if currentScoreIndex == 1:
		return

	if initialized == true:
		frameCount += 1
		if frameSkip > 0 and frameCount < frameSkip:
			return
		else:
			frameCount = 0

		process_one_score($CenterContainer/TextureRect2/VBoxContainer/HBoxContainerP1/ScoreOneLabel, delta)
#		Global.debug("s="+str(score)+" bs="+str(baseScore)+"  d="+str(delta))
#		prevScore = score
#		score = lerp(score, baseScore, 0.22)
#		if prevScore == score:
#			Global.debug("ps==s, lerp 1")
#			score = lerp(score, baseScore, 1)
#		if score == baseScore:
#			Global.debug("final score value reached")
#			scoresProcessed[0] = true
#			currentScoreIndex += 1
#
#		$MarginContainer/TextureRect2/VBoxContainer/HBoxContainerP1/ScoreOneLabel.text = str(score)

func process_one_score(label: Node, delta : float) -> void:
	Global.debug("s="+str(score)+" bs="+str(baseScore)+"  d="+str(delta))
	prevScore = score
	score = lerp(score, baseScore, 0.012)	#0.22 base
	
	if prevScore == score:
		Global.debug("ps==s, lerp 1")
		score = lerp(score, baseScore, 1)
		
	if score == baseScore:
		Global.debug("final score value reached")
		scoresProcessed[0] = true
		currentScoreIndex += 1
	
	label.text = str(score)
	
func set_score(scores: Array, playersCount: int) -> void:
	Global.debug("scr="+str(scores)+" nop="+str(playersCount))
	#first basic display of score
	if playersCount == 1:
		#$MarginContainer/TextureRect2/VBoxContainer/HBoxContainerP1/ScoreOneLabel.text = str(scores[0])
		$CenterContainer/TextureRect2/VBoxContainer/HBoxContainerP2.hide()
	else:
		$CenterContainer/TextureRect2/VBoxContainer/HBoxContainerP1/ScoreOneLabel.text = str(scores[0])
		$CenterContainer/TextureRect2/VBoxContainer/HBoxContainerP2/ScoreTwoLabel.text = str(scores[1])


func _on_button_pressed():
	hide()
	is_closed.emit()


# to remove
#func _on_visibility_changed():
	#Global.debug("final score panel vis changed:"+str(visible))

# ~unused
func _on_v_box_container_item_rect_changed():
	pass # Replace with function body.
