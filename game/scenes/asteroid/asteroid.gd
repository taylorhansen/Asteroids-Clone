extends Area2D

signal destroyed
export(Vector2) var velocity = Vector2(0, 0)

func get_hitbox_radius():
	return get_node("hitbox").get_shape().get_radius()

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	_move()
	if (_is_out_of_bounds()):
		emit_signal("destroyed", self)

# moves according to the velocity
func _move():
	set_pos(get_pos() + velocity)

# check if it went out of bounds
func _is_out_of_bounds():
	var r = get_item_and_children_rect()
	r.pos = get_global_pos()
	return not get_viewport_rect().intersects(r)
