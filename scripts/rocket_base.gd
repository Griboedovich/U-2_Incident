class_name Rocket extends RigidBody2D
# Базовый класс ракет от которого будут 
# Наследоваться все другие ракеты

# Задаём имя анимации полёта для всех видов ракет
@export var animation_name: String = "fly"
@export var explosion_scene: PackedScene

var velocity_value: Vector2

# Функция запускается при первой загрузке ноды
# Нужна что бы запустить анимацию при появлении
# Ракеты
func _ready() -> void:
	# Устанавливаем в проигрователе анимацию полёта
	if $AnimatedSprite2D.get_sprite_frames().has_animation(animation_name):
		$AnimatedSprite2D.animation = animation_name
		# Запускаем анимацию
		$AnimatedSprite2D.play(animation_name)
	
	#Выбор случайной анимации (если есть несколько)
	#var x = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	#$AnimatedSprite2D.animation = x.pick_random()
	#$AnimatedSprite2D.play()

# Функция - приёмник от VisibleOnScreenNotifier2D которая 
# Испускает сигнал когда объект исчезает из поля видимости
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#Удаление сцены в конце текущего кадра
	queue_free()

func explode() -> void:
	if not (explosion_scene == null):
		var explosion = explosion_scene.instantiate()
		explosion.position = self.position
		explosion.rotation = self.rotation
		self.get_parent().add_child(explosion)
	self.queue_free()

func freeze() -> void:
	velocity_value = self.linear_velocity
	self.linear_velocity = Vector2.ZERO
	# Отключаем коллизии у TeamKiller-ов
	collision_mask = 4
	
func unfreeze() -> void:
	self.linear_velocity = velocity_value
	velocity_value = Vector2.ZERO
