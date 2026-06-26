extends Area2D

signal treasure_collected


func _on_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	treasure_collected.emit()
	queue_free()


# If treasure ever overlap, destroy them
func _on_area_entered(_area: Area2D) -> void:
	queue_free()
