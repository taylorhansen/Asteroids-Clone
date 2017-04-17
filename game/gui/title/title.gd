extends Node2D

func _ready():
	get_node("high_score").set_text("High score: " + str(global.get_high_score()))
	get_node("play").connect("button_down", self, "_start_game")

func _start_game():
	global.goto_scene("res://scenes/space/space.tscn")
