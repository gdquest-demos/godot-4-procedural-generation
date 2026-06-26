extends Node2D

const CLEAR_COLOR := Color("#181425")

@export var level_size := Vector2(100, 80)
@export var rooms_size := Vector2(10, 14)
@export var rooms_max := 15

@onready var level_tile_map_layer: TileMapLayer = %LevelTileMapLayer
@onready var camera: Camera2D = %Camera2D


func _ready() -> void:
	RenderingServer.set_default_clear_color(CLEAR_COLOR)
	_setup_camera()
	_generate()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_select"):
		_generate()


func _setup_camera() -> void:
	camera.position = level_tile_map_layer.map_to_local(level_size / 2)
	var z := 10.0 / maxf(level_size.x, level_size.y)
	camera.zoom = Vector2(z, z)


func _generate() -> void:
	level_tile_map_layer.clear()
	for vector in BasicDungeonGenerator.generate(level_size, rooms_size, rooms_max):
		level_tile_map_layer.set_cell(vector, 0, Vector2i.ZERO, 0)
