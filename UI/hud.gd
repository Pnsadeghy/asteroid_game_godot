extends Control

@onready var lives = $Lives

@onready var score = $Score:
	set(value):
		score.text = "SCORE: " + str(value)
		
var ui_life_scene = preload("res://UI/ui_life.tscn")

func init_lives(amount):
	for ui in lives.get_children():
		ui.queue_free()
	for i in amount:
		var ui = ui_life_scene.instantiate()
		lives.add_child(ui)
