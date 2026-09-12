extends Rocket



func _on_body_shape_entered(
	body_rid: RID,
	body: Node,
	body_shape_index: int,
	local_shape_index: int
) -> void:
	call_deferred("explode")

func off_teamkill() -> void:
	# Отключаем коллизии у TeamKiller-ов
	collision_mask = 4
