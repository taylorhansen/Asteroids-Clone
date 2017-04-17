extends Node2D

func _ready():
	get_node("play").connect("button_down", self, "_start_game")

func _start_game():
	get_node("/root/global").goto_scene("res://scenes/space/space.tscn")
