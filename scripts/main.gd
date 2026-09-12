extends Node

@export var sr_25_scene: PackedScene
@export var error_scene: PackedScene
@export var teamkiller_scene: PackedScene

@export var speed_range: Vector2 = Vector2(150,250)

@export var game_mode: Dictionary[String, int] = {
	"normal": 0,
	"hell_yeah": 1,
}

@export var freeze_countdown_range: Vector2 = Vector2(15,30)
@export var freeze_range: Vector2 = Vector2(1,6)
@export var safe_frezing_rocket_count: int = 50

@export var rockets_type: Dictionary[String, int] = {
	"base": 50,
	"error": 10,
	"teamkiller": 40
}

@export var rockets_behaviors: Dictionary[String, int] = {
		"stupid": 50,
		"smart-scattering": 30,
		"smart": 20
	}

var score
var scroll_speed: int
var temporary_timer: Timer
var spawn_time: float
var teamkiller_chance: int
var is_freezing: bool = false
var freezing_rocket_count: int = 0

func _ready() -> void:
	scroll_speed = $BackgroundManager.scroll_speed
	spawn_time = $RocketTimer.wait_time
	teamkiller_chance = rockets_type["teamkiller"]


func new_game() -> void:
	# Возвращаем адекватные значения после hell_yeah
	is_freezing = false
	$"RocketTimer".wait_time = spawn_time
	rockets_type["teamkiller"] = teamkiller_chance
	get_tree().call_group("freezing", "unfreeze")
	$ScoreTimer.paused = false
	freezing_rocket_count = 0
	if temporary_timer != null:
		temporary_timer.queue_free()
	
	score = 0
	$StartTimer.start()
	$Player.start($StartPozition.position)
	
	$Hud.update_score(score)
	$Hud.show_message("Сосредоточься")
	
	get_tree().call_group("rockets", "queue_free")
	
	match get_random_object(game_mode):
		"normal":
			pass
		"hell_yeah":
			start_freeze_countdown()
		_:
			printerr("Отсутствующий режим")


func game_over() -> void:
	if temporary_timer != null:
		temporary_timer.queue_free()
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
	if freezing_rocket_count >= safe_frezing_rocket_count:
		return
	elif is_freezing:
		freezing_rocket_count += 1
	
	var rocket: Rocket
	var direction: float
	var rocket_spawn_location: PathFollow2D = (
		$"RocketPath/RocketSpawnLocation"
	)
	
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
	
	if is_freezing:
		rocket.freeze()
	
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

func start_freeze_countdown() -> void:
	var freeze_countdown_timer: Timer = Timer.new()
	self.add_child(freeze_countdown_timer)
	freeze_countdown_timer.wait_time = randf_range(
		freeze_countdown_range.x,
		freeze_countdown_range.y
	)
	freeze_countdown_timer.one_shot = true
	freeze_countdown_timer.timeout.connect(
		_on_freeze_countdown_timeout
	)
	freeze_countdown_timer.start()
	
	if temporary_timer != null:
		temporary_timer.queue_free()
	temporary_timer = freeze_countdown_timer

func _on_freeze_countdown_timeout() -> void:
	var freeze_timer: Timer = Timer.new()
	self.add_child(freeze_timer)
	freeze_timer.one_shot = true
	freeze_timer.wait_time = randf_range(
		freeze_range.x,
		freeze_range.y
	)
	freeze_timer.timeout.connect(_on_freeze_timeout)
	
	is_freezing = true
	get_tree().call_group("freezing", "freeze")
	$ScoreTimer.paused = true
	rockets_type["teamkiller"] = -1
	$RocketTimer.wait_time = 0.05
	
	freeze_timer.start()
	
	if temporary_timer != null:
		temporary_timer.queue_free()
	temporary_timer = freeze_timer
	
func _on_freeze_timeout() -> void:
	
	get_tree().call_group("freezing", "unfreeze")
	is_freezing = false
	$"RocketTimer".wait_time = spawn_time
	$ScoreTimer.paused = false
	
	if temporary_timer != null:
		temporary_timer.queue_free()
