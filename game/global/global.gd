extends Node

# last child of root is always the currently loaded scene
onready var current_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
var _high_score = 0

func _ready():
	pass

func get_high_score():
	return _high_score

# switches the current scene to a new one
func goto_scene(path):
	# could be inside a callback or something like that, so defer until later
	call_deferred("_deferred_goto_scene", path)

func process_score(score):
	if (score > _high_score):
		_high_score = score

func _deferred_goto_scene(path):
	current_scene.free()
	current_scene = ResourceLoader.load(path).instance()
	get_tree().get_root().add_child(current_scene)
