extends Area2D

signal destroyed
const HIT_ASTEROID = true
export(Vector2) var velocity = Vector2(0, 0)

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	_move()
	_check_asteroids()
	if (_is_out_of_bounds()):
		emit_signal("destroyed", self)

# moves according to the velocity
func _move():
	set_pos(get_pos() + velocity)

# checks if it hit any asteroids
func _check_asteroids():
	var areas = get_overlapping_areas()
	for area in areas:
		if (area.is_in_group("asteroids")):
			# hey, i hit an asteroid!
			area.emit_signal("destroyed", area)
			emit_signal("destroyed", self, HIT_ASTEROID)
			break

# check if it went out of bounds
func _is_out_of_bounds():
	var r = get_item_and_children_rect()
	r.pos = get_global_pos()
	return not get_viewport_rect().intersects(r)
