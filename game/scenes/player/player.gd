extends Area2D

signal destroyed
signal update_health
signal update_score
const MISSILE_SCENE = preload("res://scenes/missile/missile.tscn")
export(float) var thrust_speed = 3.0
export(float) var rot_speed = 1.5 * PI # radians per second
export(int) var initial_health = 3
var _just_shot_missile = true
var _health = initial_health

func get_health():
	return _health

func get_hitbox_radius():
	return get_node("hitbox").get_shape().get_radius()

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	_process_input(delta)
	_check_collisions()

func _process_input(delta):
	# possibly shoot a missile
	if (Input.is_action_pressed("player_shoot")):
		if (not _just_shot_missile):
			_spawn_missile()
			_just_shot_missile = true
	else:
		_just_shot_missile = false
	# get input data
	var thrust = 0
	if (Input.is_action_pressed("player_up")):
		thrust += thrust_speed
	if (Input.is_action_pressed("player_down")):
		thrust -= thrust_speed
	var rot = get_rot()
	if (Input.is_action_pressed("player_left")):
		rot += rot_speed * delta
	if (Input.is_action_pressed("player_right")):
		rot -= rot_speed * delta
	# update rotation
	set_rot(rot)
	# update position
	var velocity = Vector2(sin(rot), cos(rot)) * thrust
	var pos = get_pos()
	var size = get_viewport_rect().size
	var radius = get_hitbox_radius()
	var new_x = fmod(pos.x + velocity.x, size.x + radius)
	if (new_x < 0):
		new_x += size.x + radius
	var new_y = fmod(pos.y + velocity.y, size.y + radius)
	if (new_y < 0):
		new_y += size.y + radius
	set_pos(Vector2(new_x, new_y))

# find out what objects are colliding with the player and respond accordingly
func _check_collisions():
	var areas = get_overlapping_areas()
	for area in areas:
		if (area.is_in_group("asteroids")):
			# hit by an asteroid
			_health -= 1
			emit_signal("update_health")
			area.queue_free()
			if (_health <= 0):
				emit_signal("destroyed")
				break

# spawns a missile where the player is at
func _spawn_missile():
	var missile = MISSILE_SCENE.instance()
	missile.connect("destroyed", self, "_destroy_missile")
	missile.set_pos(get_pos())
	var rot = get_rot()
	missile.set_rot(rot)
	# the vector is already normalized so it's scaled to have a reasonable speed
	missile.velocity = Vector2(sin(rot), cos(rot)) * 4
	get_node("missiles").add_child(missile)

# destroys a missile, updating the score if it was because of an asteroid
func _destroy_missile(missile, hit_asteroid = false):
	missile.queue_free()
	if (hit_asteroid):
		emit_signal("update_score")
