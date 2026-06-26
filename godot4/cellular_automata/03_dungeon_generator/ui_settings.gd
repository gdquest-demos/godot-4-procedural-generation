extends Control

signal min_exit_distance_changed(value: int)
signal min_cavern_area_changed(value: int)
signal maximum_treasure_changed(value: int)

signal wall_chance_changed(value: float)
signal wall_conversion_changed(value: int)
signal floor_conversion_changed(value: int)

signal step_count_changed(value: int)
signal step_time_changed(time: float)

@onready var generate_button: Button = %GenerateButton

@onready var minimum_exit_distance_value: Label = %MinimumExitDistance/Value
@onready var minimum_cavern_area_value: Label = %MinimumCavernArea/Value
@onready var maximum_treasure_value: Label = %MaximumTreasure/Value

@onready var wall_chance_value: Label = %WallChance/Value
@onready var wall_conversion_value: Label = %WallConversion/Value
@onready var floor_conversion_value: Label = %FloorConversion/Value

@onready var step_count_value: Label = %StepCount/Value
@onready var step_time_value: Label = %StepTime/Value


func enable() -> void:
	generate_button.disabled = false


func disable() -> void:
	generate_button.disabled = true


func _on_minimum_exit_distance_value_changed(value: float) -> void:
	var int_value := int(value)
	minimum_exit_distance_value.text = "%s" % int_value
	min_exit_distance_changed.emit(int_value)


func _on_minimum_cavern_area_value_changed(value: float) -> void:
	var int_value := int(value)
	minimum_cavern_area_value.text = "%s" % int_value
	min_cavern_area_changed.emit(int_value)


func _on_maximum_treasure_value_changed(value: float) -> void:
	var int_value := int(value)
	maximum_treasure_value.text = "%s" % int_value
	maximum_treasure_changed.emit(int_value)


func _on_wall_chance_value_changed(value: float) -> void:
	wall_chance_value.text = "%s" % value
	wall_chance_changed.emit(value)


func _on_wall_conversion_value_changed(value: float) -> void:
	var int_value := int(value)
	wall_conversion_value.text = "< %s" % int_value
	wall_conversion_changed.emit(int_value)


func _on_floor_conversion_value_changed(value: float) -> void:
	var int_value := int(value)
	floor_conversion_value.text = "> %s" % int_value
	floor_conversion_changed.emit(value)


func _on_step_count_value_changed(value: float) -> void:
	var int_value := int(value)
	step_count_value.text = "%s" % int_value
	step_count_changed.emit(value)


func _on_step_time_value_changed(value: float) -> void:
	step_time_value.text = "%s" % value
	step_time_changed.emit(value)
