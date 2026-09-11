extends Rocket



func _on_body_shape_entered(
	body_rid: RID,
	body: Node,
	body_shape_index: int,
	local_shape_index: int
) -> void:
	call_deferred("explode")
