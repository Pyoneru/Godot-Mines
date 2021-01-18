extends Node2D


onready var level = Settings.Level.NORMAL


func _on_Easy_Level_pressed():
	setSelected(Settings.Level.EASY, 200)


func _on_Normal_Level_pressed():
	setSelected(Settings.Level.NORMAL, 312)


func _on_Hard_Level_pressed():
	setSelected(Settings.Level.HARD, 424)


func setSelected(lvl, pos):
	level = lvl
	$Selected.rect_position.x = pos


func _on_Start_pressed():
	Settings.level = level
	get_tree().change_scene("res://Game/Game.tscn")
