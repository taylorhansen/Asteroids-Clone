extends Area2D

signal destroyed
signal update_health
signal update_score
const MISSILE_SCENE = preload("res://scenes/missile/missile.tscn")
const MAX_THRUST = 8.0 # pixels per second
export(float) var thrust_speed = 4.0 # pixels per second squared
export(float) var brake_speed = 8.0 # pixels per second squared
export(float) var rot_speed = 1.5 * PI # radians per second
export(int) var initial_health = 3
var _just_shot_missile = true
var _health = initial_health
var _thrust = 0

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
	if (Input.is_action_pressed("player_up")):
		_thrust = min(_thrust + (thrust_speed * delta), MAX_THRUST)
	if (Input.is_action_pressed("player_down")):
		_thrust = max(_thrust - (brake_speed * delta), 0)
	var rot = 0
	if (Input.is_action_pressed("player_left")):
		rot += rot_speed * delta
	if (Input.is_action_pressed("player_right")):
		rot -= rot_speed * delta
	# update position and rotation
	var transform = get_transform().translated(Vector2(0, _thrust)).rotated(rot)
	# account for the player going out of bounds (teleport to the other side)
	var size = get_viewport_rect().size
	transform.o = Vector2(fmod(transform.o.x, size.x), fmod(transform.o.y, size.y))
	if (transform.o.x < 0):
		transform.o.x += size.x
	if (transform.o.y < 0):
		transform.o.y += size.y
	set_transform(transform)

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
	missile.set_transform(get_transform())
	get_node("missiles").add_child(missile)

# destroys a missile, updating the score if it was because of an asteroid
func _destroy_missile(missile, hit_asteroid = false):
	missile.queue_free()
	if (hit_asteroid):
		emit_signal("update_score")
