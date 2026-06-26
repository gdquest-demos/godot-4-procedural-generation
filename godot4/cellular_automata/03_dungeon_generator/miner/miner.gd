extends CharacterBody2D

signal drill_used(dig_positions: Array[Vector2])

@export var speed := 500

const DRILL_RANGE := 100

@onready var pivot_marker := %PivotMarker2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var dig_positions: Array[Vector2] = []
		var angles_of_attack := [0, PI / 6, -PI / 6]
		for angle in angles_of_attack:
			dig_positions.append(global_position + Vector2.RIGHT.rotated(pivot_marker.rotation + angle) * DRILL_RANGE)
		drill_used.emit(dig_positions)


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	pivot_marker.look_at(global_position + direction)
	velocity = direction * speed
	move_and_slide()
