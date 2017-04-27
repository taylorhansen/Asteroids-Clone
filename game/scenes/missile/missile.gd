extends Area2D

signal destroyed
const HIT_ASTEROID = true
export(float) var speed = 256.0 # pixels per second
export(float) var lifetime = 1.0 # seconds

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	_move(delta)
	_check_asteroids()
	lifetime -= delta
	if (lifetime < 0.0):
		emit_signal("destroyed", self)

# moves according to the speed
func _move(delta):
	move_local_y(speed * delta, true)
	# account for the missile going out of bounds (teleport to the other side)
	var pos = get_pos()
	var size = get_viewport_rect().size
	pos = Vector2(fmod(pos.x, size.x), fmod(pos.y, size.y))
	if (pos.x < 0):
		pos.x += size.x
	if (pos.y < 0):
		pos.y += size.y
	set_pos(pos)

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
