extends Node

# last child of root is always the currently loaded scene
onready var current_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)

func _ready():
	pass

# switches the current scene to a new one
func goto_scene(path):
	# could be inside a callback or something like that, so defer until later
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	current_scene.free()
	current_scene = ResourceLoader.load(path).instance()
	get_tree().get_root().add_child(current_scene)
