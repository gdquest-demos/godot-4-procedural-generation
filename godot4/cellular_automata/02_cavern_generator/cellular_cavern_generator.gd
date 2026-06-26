## Generates a cavern using an algorithm based on celular automata.
extends Node2D

enum CellType { FLOOR, WALL }

const NEIGHBORS: Array[Vector2i] = [
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT + Vector2i.UP,
	Vector2i.LEFT + Vector2i.DOWN,
	Vector2i.RIGHT + Vector2i.UP,
	Vector2i.ONE,
]

var _map: Dictionary[Vector2i, CellType] = { }

const MAP_SIZE := Vector2i(80, 45)

var wall_chance := 0.5:
	set = set_wall_chance
var wall_conversion := 4:
	set = set_wall_conversion
var floor_conversion := 4:
	set = set_floor_conversion

var step_count := 10:
	set = set_step_count
var step_time := 0.1:
	set = set_step_time

@onready var dungeon_tile_map_layer: TileMapLayer = %DungeonTileMapLayer


func _ready() -> void:
	generate_new_dungeon()


func generate_new_dungeon() -> void:
	_map = _generate_random_map()

	# We slow down the generation and draw it for visualization purposes.
	for step in step_count:
		if step_time > 0:
			_paint_map()
			await get_tree().create_timer(step_time).timeout
		_map = _advance_simulation()

	_paint_map()


## Generates a dictionary representing a map with random walls and floors.
func _generate_random_map() -> Dictionary[Vector2i, CellType]:
	var map: Dictionary[Vector2i, CellType] = { }
	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			map[Vector2i(x, y)] = CellType.WALL if randf() < wall_chance else CellType.FLOOR
	return map


## Advances the cellular automata simulation by one step
func _advance_simulation() -> Dictionary[Vector2i, CellType]:
	var new_map: Dictionary[Vector2i, CellType] = { }
	for cell in _map:
		var floor_neighbor_count = _count_floor_neighbors(cell)
		if _map[cell] == CellType.WALL:
			new_map[cell] = (
					CellType.FLOOR
					if floor_neighbor_count > floor_conversion
					else CellType.WALL
			)
		else:
			new_map[cell] = (
					CellType.WALL
					if 8 - floor_neighbor_count > wall_conversion
					else CellType.FLOOR
			)
	return new_map


## Draws tiles on the dungeon_tile_map_layer.
func _paint_map() -> void:
	for cell in _map:
		dungeon_tile_map_layer.set_cell(cell, 0, Vector2i(_map[cell], 0))


## Returns the number of neighboring cells that are of type FLOOR.
func _count_floor_neighbors(location: Vector2i) -> int:
	var count = 0
	for neighbor in NEIGHBORS:
		var check_location := location + neighbor
		if not _map.has(check_location):
			continue
		if _map[check_location] == CellType.FLOOR:
			count += 1
	return count


func set_wall_chance(value: float) -> void:
	wall_chance = value


func set_step_time(value: float) -> void:
	step_time = value


func set_wall_conversion(value: int) -> void:
	wall_conversion = value


func set_floor_conversion(value: int) -> void:
	floor_conversion = value


func set_step_count(value: int) -> void:
	step_count = value
