extends Area2D

signal miner_entered


func _on_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	miner_entered.emit()
