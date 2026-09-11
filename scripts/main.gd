extends Node

@export var sr_25_scene: PackedScene
@export var error_scene: PackedScene

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
	$"Sr-75Timer".stop()
	$ScoreTimer.stop()
	
	$Hud.show_game_over()



func _on_start_timer_timeout() -> void:
	$"Sr-75Timer".start()
	$ScoreTimer.start()


func _on_score_timer_timeout() -> void:
	score += 1
	$Hud.update_score(score)


func _on_sr_75_timer_timeout() -> void:
	#  Заглушка - передалать
	var randum = randi() % 2
	var rocket: RigidBody2D
	
	if randum % 2 == 0:
		rocket = sr_25_scene.instantiate()
	else:
		rocket = error_scene.instantiate()
	
	# ====================
	
	#var rocket: RigidBody2D = sr_25_scene.instantiate()
	var rocket_spawn_location = $"Sr-75Path/Sr-75SpawnLocation"
	rocket_spawn_location.progress_ratio = randf()
	
	rocket.position = rocket_spawn_location.position
	
	var direction: float
	
	if smart_rockets:
		#-------------------Поврот ракеты к игроку--------
		direction = ($Player.position - rocket_spawn_location.position).angle() + PI/2
		
		if (random_direction):
			direction += randf_range(-PI / 6, PI / 6)
		#-------------------------------------------------
	else:
		#------------Случайный поврот ракеты-------------
		direction = rocket_spawn_location.rotation + PI
		direction += randf_range(-PI / 4, PI / 4)
		#-------------------------------------------------
	
	
	rocket.rotation = direction
	
	# ScrollSpeed заставляет падать как вверх так и вниз
	# в виду того, что у них 
	
	var velocity = Vector2(0, randf_range(speed_range.x, speed_range.y))
	rocket.linear_velocity = velocity.rotated(direction + PI)
	
	add_child(rocket)
	
