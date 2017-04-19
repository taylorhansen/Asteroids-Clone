extends Node

const NEW_HIGH_SCORE = 1
const MAX_LEADERBOARD_RECORDS = 3
const _DEFAULT_DATA = {"leaderboard":[]}
const _SAVE_PATH = "user://save.json"
onready var _root = get_tree().get_root()
onready var _current_scene = _root.get_child(_root.get_child_count() - 1)
var _save_data = _load_save()

func _ready():
	pass

func _exit_tree():
	print(_save_data)
	_store_save(_save_data)

func get_high_score():
	if (not _save_data["leaderboard"].empty()):
		return _save_data["leaderboard"][0]["score"]
	return 0

func get_leaderboard():
	return _save_data["leaderboard"]

func clear_save_data():
	_save_data = _DEFAULT_DATA
	_store_save(_save_data)

func update_leaderboard(name, score):
	# assumed that score is the new high score
	var record = {"name":name, "score":score}
	if (_save_data["leaderboard"].size() >= MAX_LEADERBOARD_RECORDS):
		_save_data["leaderboard"].pop_back()
	_save_data["leaderboard"].push_front(record)

# switches the current scene to a new one
func goto_scene(path):
	# could be inside a callback or something like that, so defer until later
	call_deferred("_deferred_goto_scene", path)

# loads the save from user data
func _load_save():
	var file = File.new()
	var data = _DEFAULT_DATA
	if (file.file_exists(_SAVE_PATH)):
		file.open(_SAVE_PATH, File.READ)
		var line = file.get_line()
		if (data.parse_json(line) != OK):
			print("error parsing save: ", line)
		file.close()
	return data

# stores the save in user data
func _store_save(data):
	var file = File.new()
	file.open(_SAVE_PATH, File.WRITE)
	file.store_line(data.to_json())
	file.close()

func _deferred_goto_scene(path):
	_current_scene.free()
	_current_scene = ResourceLoader.load(path).instance()
	_root.add_child(_current_scene)
