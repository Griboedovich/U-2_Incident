extends RigidBody2D

@export var animation_name: String = "explosion"

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
