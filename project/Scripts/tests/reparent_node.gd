extends Control

var tileTestScene : PackedScene = preload("res://Scenes/tileA.tscn")
var tileTest : Node2D

func _ready():
	tileTest = tileTestScene.instantiate()
	$HBoxContainer/Parent1.add_child(tileTest)
	
func _on_reparent_1_pressed():
	$HBoxContainer/Parent2.remove_child(tileTest)
	$HBoxContainer/Parent1.add_child(tileTest)

func _on_reparent_2_pressed():
	$HBoxContainer/Parent1.remove_child(tileTest)
	$HBoxContainer/Parent2.add_child(tileTest)
