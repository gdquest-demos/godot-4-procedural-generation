extends Control

signal wall_chance_changed(value: int)
signal wall_conversion_changed(value: int)
signal floor_conversion_changed(value: int)
signal step_count_changed(value: int)
signal step_time_changed(time: float)

@onready var button_generate: Button = %GenerateButton

@onready var wall_chance_value: Label = %WallChance/Value
@onready var wall_conversion_value: Label = %WallConversion/Value
@onready var floor_conversion_value: Label = %FloorConversion/Value

@onready var step_count_value: Label = %StepCount/Value
@onready var step_time_value: Label = %StepTime/Value


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
	floor_conversion_changed.emit(int_value)


func _on_step_count_value_changed(value: float) -> void:
	var int_value := int(value)
	step_count_value.text = "%s" % int_value
	step_count_changed.emit(int_value)


func _on_step_time_value_changed(value: float) -> void:
	step_time_value.text = "%s" % value
	step_time_changed.emit(value)
