extends Label

func _ready():
	pass

func set_record(record):
	set_text(str(record["name"]) + ": " + str(record["score"]))
