extends Node2D

func _ready():
	get_node("high_score").set_text("High score: " + str(global.get_save_data().high_score))
	get_node("play").connect("button_down", self, "_play")
	get_node("options").connect("button_down", self, "_options")

func _play():
	global.goto_scene("res://scenes/space/space.tscn")

func _options():
	global.goto_scene("res://gui/options/options.tscn")
