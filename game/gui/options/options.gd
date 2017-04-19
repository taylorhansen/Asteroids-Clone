extends Node2D

func _ready():
	get_node("back_to_title").connect("button_down", self, "_back_to_title")
	get_node("clear_data").connect("button_down", self, "_clear_data")

func _back_to_title():
	global.goto_scene("res://gui/title/title.tscn")

func _clear_data():
	global.clear_save_data()
