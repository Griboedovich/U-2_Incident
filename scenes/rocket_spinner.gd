extends Rocket

var rotation_speed: float = PI
var result_rotation: float

var is_freeze: bool = false

func _ready() -> void:
	# Устанавливаем в проигрователе анимацию полёта
	if $AnimatedSprite2D.get_sprite_frames().has_animation(animation_name):
		$AnimatedSprite2D.animation = animation_name
		# Запускаем анимацию
		$AnimatedSprite2D.play(animation_name)
	
	var rotation_direction = randi() % 2
	if rotation_direction:
		rotation_speed *= -1
	
	result_rotation = $AnimatedSprite2D.rotation

func _physics_process(delta: float) -> void:
	if not is_freeze:
		var rotation_v: float = rotation_speed * delta
		$AnimatedSprite2D.rotation += rotation_v
		$CollisionShape2D.rotation += rotation_v
		$VisibleOnScreenNotifier2D.rotation += rotation_v
		result_rotation += rotation_v
	

func explode() -> void:
	if not (explosion_scene == null):
		var explosion = explosion_scene.instantiate()
		explosion.position = self.position
		explosion.rotation = result_rotation
		self.get_parent().add_child(explosion)
	self.queue_free()

func freeze() -> void:
	velocity_value = self.linear_velocity
	self.linear_velocity = Vector2.ZERO
	is_freeze = true
	
	
func unfreeze() -> void:
	self.linear_velocity = velocity_value
	velocity_value = Vector2.ZERO
	is_freeze = false
