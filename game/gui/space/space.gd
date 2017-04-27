extends Node2D

const ASTEROID_SCENE = preload("res://scenes/asteroid/asteroid.tscn")
const MAX_ASTEROID_SPEED = 5
export(int) var max_asteroids = 0
onready var player = get_node("player")
var _dead = false
var _asteroids = 0
var _asteroid_speed = 1
var _score = 0

func _ready():
	# seed the random number generator
	randomize()
	# setup the hud
	_display_health()
	_display_score()
	# connect signals
	player.connect("destroyed", self, "_game_over")
	player.connect("update_health", self, "_display_health")
	player.connect("update_score", self, "_update_score")
	get_node("high_score_popup/ok").connect("button_down", self, "_update_leaderboard")
	# start the process loop
	set_process(true)

func _process(delta):
	# spawn an asteroid if able
	if (not _dead):
		if (_can_spawn_asteroid() and _spawn_asteroid_succeeded()):
			_asteroids += 1
	else:
		global.goto_scene("res://gui/title/title.tscn")

func _display_health():
	get_node("health").set_text("Health: " + str(player.get_health()))

func _display_score():
	get_node("score").set_text("Score: " + str(_score))

func _game_over():
	print("game over!")
	if (global.get_high_score() < _score):
		set_process(false)
		get_node("high_score_popup").popup()
	_dead = true
	player.queue_free()
	get_node("asteroids").queue_free()

func _update_score():
	_score += 10
	_asteroid_speed = min(_score / 50.0 + 1.0, MAX_ASTEROID_SPEED)
	_display_score()

func _update_leaderboard():
	print("updating leaderboard")
	var name = get_node("high_score_popup/name_edit").get_text()
	global.update_leaderboard(name, _score)
	set_process(true)

# returns true if all clear to attempt spawning an asteroid
func _can_spawn_asteroid():
	return (_asteroids <= max_asteroids and randi() % 32 == 0)

# attempts to spawn an asteroid away from the player, returning true if successful
func _spawn_asteroid_succeeded():
	# generate a random position within the viewport
	var size = get_viewport_rect().size
	var random_pos = Vector2(randi() % int(size.x), randi() % int(size.y))
	# calculate the minimum distance away from the player
	var asteroid = ASTEROID_SCENE.instance()
	var min_dist = asteroid.get_hitbox_radius() + (2.0 * player.get_hitbox_radius())
	# continue if the random position is distant enough from the player
	if (random_pos.distance_squared_to(player.get_pos()) > min_dist * min_dist):
		asteroid.set_pos(random_pos)
		# create a random velocity and scale it by the speed scalar
		var velocity = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
		asteroid.velocity = velocity * _asteroid_speed
		asteroid.connect("destroyed", self, "_destroy_asteroid")
		get_node("asteroids").add_child(asteroid)
		return true
	else:
		# failed to create an asteroid away from the player
		asteroid.queue_free()
		return false

func _destroy_asteroid(asteroid):
	asteroid.queue_free()
	_asteroids -= 1
