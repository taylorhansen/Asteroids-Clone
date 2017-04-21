extends ScrollContainer

const _RECORD_SCENE = preload("res://gui/record/record.tscn")
onready var _records = get_node("records")

func _ready():
	pass

func load_leaderboard(leaderboard):
	for child in _records.get_children():
		child.queue_free()
	for record in leaderboard:
		var record_node = _RECORD_SCENE.instance()
		record_node.set_record(record)
		_records.add_child(record_node)
