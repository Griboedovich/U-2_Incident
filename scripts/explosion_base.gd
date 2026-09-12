extends RigidBody2D

@export var animation_name: String = "explosion"

var velocity_value: Vector2

func _ready() -> void:
	# Устанавливаем в проигрователе анимацию полёта
	if $AnimatedSprite2D.get_sprite_frames().has_animation(animation_name):
		$AnimatedSprite2D.animation = animation_name
		# Запускаем анимацию
		$AnimatedSprite2D.play(animation_name)


func _on_animation_finished() -> void:
	queue_free()


func _on_body_shape_entered(
	body_rid: RID,
	body: Node,
	body_shape_index: int,
	local_shape_index: int
) -> void:
	if body is Rocket:
		var rocket = body as Rocket
		rocket.call_deferred("explode")

func freeze() -> void:
	velocity_value = self.linear_velocity
	self.linear_velocity = Vector2.ZERO
	$AnimatedSprite2D.pause()
	$CollisionShape2D.set_deferred("disabled", true)
	
func unfreeze() -> void:
	self.linear_velocity = velocity_value
	velocity_value = Vector2.ZERO
	$AnimatedSprite2D.play()
