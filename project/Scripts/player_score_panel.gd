extends Control

@export var playerIdx : int = 1
@export var playerLabel : String
var labelTween

var debug_tween_launched : bool = false

func _ready():
	$"Background/VBoxContainer/Player Label".text = playerLabel
	$"Background/VBoxContainer/HBoxContainer/Player Score".text = "----"
	$"Background/VBoxContainer/HBoxContainer/FourWays Counter".text = "--"


func update_player_score(points: int) -> void:
	$"Background/VBoxContainer/HBoxContainer/Player Score".text = "%4d" % points

func update_player_fways_counter(points: int) -> void:
	$"Background/VBoxContainer/HBoxContainer/FourWays Counter".text = "%2d" % points
	
func highlight_current_player(duration : float)-> void:
	if labelTween!= null and labelTween.is_valid():
		Global.debug("play valid tween")
		labelTween.play()
	else:
		Global.debug("setup invalid tween")
		labelTween = self.create_tween()
		labelTween.set_loops()
		labelTween.tween_property($"Background/VBoxContainer/Player Label", "theme_override_constants/outline_size", 8, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		labelTween.tween_property($"Background/VBoxContainer/Player Label", "theme_override_constants/outline_size", 4, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
func stop_highlight_current_player() -> void:
	if labelTween.is_valid() and labelTween.is_running():
		Global.debug("pause valid tween")
		labelTween.pause()
		$"Background/VBoxContainer/Player Label".add_theme_constant_override("outline_size", 4)
	else:
		Global.debug("invalid tween or not running")
