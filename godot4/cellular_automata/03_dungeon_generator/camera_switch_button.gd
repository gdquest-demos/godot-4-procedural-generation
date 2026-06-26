extends Button

@export var camera_one: Camera2D = null
@export var camera_two: Camera2D = null


func _on_pressed() -> void:
	if camera_one.is_current():
		camera_two.make_current()
	else:
		camera_one.make_current()
