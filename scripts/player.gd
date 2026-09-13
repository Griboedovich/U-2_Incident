extends Area2D

# Сигнал, который испускается при попадании ракеты
# В самолёт
signal hit

# Cкорость: пиксели в секунду
@export var speed: int = 400 
@export var explosion_scene: PackedScene

var collision_shape: CollisionPolygon2D

#Размер игрового окна
var screen_size: Vector2
# Размер игрока 
var player_size: Vector2 = Vector2(160,120)

var is_freezing: bool = false

# Функция вызывается при первой загрузке сцены
func _ready() -> void:
	# Сохраняем в переменную форму коллизии для Area3D (Player)
	collision_shape = $PlayerShape
	# Устанавливаем размер окна
	# Размер окна узнаём через размер области просмотра
	screen_size = get_viewport_rect().size
	# Скрываем ноду
	hide()

# Функция вызывается каждый игровой кадр
func _process(delta: float) -> void:
	# Обьявляем переменную - вектор скорости
	var velocity: Vector2 = Vector2.ZERO
	# Проверяем нажата ли кнопка
	# Взавимисоти от кнопки придаём направление вектору скорости
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	
	# Если значение скорости не нулевое
	if velocity.length() != 0:
		velocity = velocity.normalized() * speed
		
	
	#Настраиваем анимацию
	if velocity.y > 0:
		$AnimatedSprite2D.animation = "down"
	elif velocity.x > 0:
		$AnimatedSprite2D.animation = "right"
	elif velocity.x < 0:
		$AnimatedSprite2D.animation = "left"
	elif velocity.y == 0:
		$AnimatedSprite2D.animation = "rest"
	else:
		$AnimatedSprite2D.animation = "up"
	
	$AnimatedSprite2D.play()
	
	if not is_freezing:
		position += velocity * delta
		position = position.clamp(Vector2.ZERO + player_size, screen_size - player_size)


func start(pos: Vector2) -> void:
	position = pos #позиция старата
	show() # отобразить ноду
	# включить форму столкновений
	collision_shape.disabled = false

# Функция вызывается когда от корневого узла типа Area3D (Player)
# Приходит сигнал "body_entered", который вызывается, когда
# PhysicsBody2D входит в Shape2D (CollisionShape2D или CollisionPolygon2D)
# Текущего узла
func _on_body_entered(body: Node2D) -> void:
	# Скрываем текущую ноду (прячем самолёт)
	hide()
	# Испускаем сигнал hit
	hit.emit()
	# Отключаем форму столкновений в конце текущего кадра,
	# Чтобы не допустить повторного вызова сигнала hit
	collision_shape.set_deferred("disabled", true)
	
	self.call_deferred("explode_player")
	
	if body is Rocket:
		var rocket: Rocket = body as Rocket
		rocket.call_deferred("explode")

func explode_player() -> void:
	if not (explosion_scene == null):
		var explosion = explosion_scene.instantiate()
		explosion.position = self.position
		explosion.rotation = self.rotation
		self.get_parent().add_child(explosion)

func freeze() -> void:
	is_freezing = true
func unfreeze() -> void:
	is_freezing = false
