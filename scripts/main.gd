extends Node

@export var sr_25_scene: PackedScene
@export var error_scene: PackedScene
@export var teamkiller_scene: PackedScene

@export var speed_range: Vector2 = Vector2(150,250)

@export var smart_rockets: bool

@export var random_direction: bool

var score
var scroll_speed: int

func _ready() -> void:
	scroll_speed = $BackgroundManager.scroll_speed


func new_game() -> void:
	score = 0
	$StartTimer.start()
	$Player.start($StartPozition.position)
	
	$Hud.update_score(score)
	$Hud.show_message("Сосредоточься")
	
	get_tree().call_group("rockets", "queue_free")

func game_over() -> void:
	$"RocketTimer".stop()
	$ScoreTimer.stop()
	
	$Hud.show_game_over()


func _on_start_timer_timeout() -> void:
	$"RocketTimer".start()
	$ScoreTimer.start()


func _on_score_timer_timeout() -> void:
	score += 1
	$Hud.update_score(score)


func _on_sr_75_timer_timeout() -> void:
	var rocket: Rocket
	var direction: float
	var rocket_spawn_location: PathFollow2D = (
		$"RocketPath/RocketSpawnLocation"
	)
	
	var rockets_type: Dictionary[String, int] = {
		"base": 50,
		"error": 10,
		"teamkiller": 40
	}
	
	var rockets_behaviors: Dictionary[String, int] = {
		"stupid": 50,
		"smart-scattering": 30,
		"smart": 20
	}
	
	match get_random_object(rockets_type):
		"base":
			rocket = sr_25_scene.instantiate()
		"error":
			rocket = error_scene.instantiate()
		"teamkiller":
			rocket = teamkiller_scene.instantiate()
		_:
			printerr("Как могла появится ракета, который нет?")
	
	rocket_spawn_location.progress_ratio = randf()
	rocket.position = rocket_spawn_location.position
	
	match get_random_object(rockets_behaviors):
		"stupid":
			direction = rocket_spawn_location.rotation + PI
			direction += randf_range(-PI / 4, PI / 4)
			rocket.rotation = direction
		"smart-scattering":
			direction = ($Player.position - rocket_spawn_location.position).angle() + PI/2
			direction += randf_range(-PI / 6, PI / 6)
			rocket.rotation = direction
		"smart":
			direction = ($Player.position - rocket_spawn_location.position).angle() + PI/2
			rocket.rotation = direction
		_:
			printerr("Как могла появится ракета, который нет?")
	
	# ScrollSpeed заставляет падать как вверх так и вниз
	# в виду того, что у них 
	
	var velocity = Vector2(0, randf_range(speed_range.x, speed_range.y))
	rocket.linear_velocity = velocity.rotated(direction + PI)
	
	add_child(rocket)

func get_random_object(objects: Dictionary[String, int]) -> String:
	var total_weight: int = 0
	var weight_sum: int = 0
	var result_object: String
	var random_value: int
	
	for object in objects.keys():
		total_weight += objects[object]
	
	random_value = randi() % total_weight + 1
	
	for object in objects.keys():
		weight_sum += objects[object]
		if random_value <= weight_sum:
			result_object =  object
			break
	
	return result_object
