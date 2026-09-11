extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.animation = "fly"
	$AnimatedSprite2D.play()
	
	#Выбор случайной анимации (если есть несколько)
	#var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	#$AnimatedSprite2D.animation = mob_types.pick_random()
	#$AnimatedSprite2D.play()

# Функция - приёмник от VisibleOnScreenNotifier2D которая испускает сигнал когда объект исчезает из поля видимости
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#Удаление сцены в конце текущего кадра
	queue_free()
