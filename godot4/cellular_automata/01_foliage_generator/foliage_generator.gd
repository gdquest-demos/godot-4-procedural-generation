extends Node2D

enum PlantState { DEAD, ALIVE }

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

@export var chance_to_start_alive := 0.52

var _map: Dictionary[Vector2i, PlantState] = { }
var _grid_size := Vector2(20, 11)

@onready var foliage_tile_map_layer: TileMapLayer = %FoliageTileMapLayer


func _ready() -> void:
	randomize()
	_initialize_map()
	_paint_map()


func _initialize_map() -> void:
	for x in range(_grid_size.x):
		for y in range(_grid_size.y):
			_map[Vector2i(x, y)] = (
					PlantState.ALIVE
					if randf() < chance_to_start_alive
					else PlantState.DEAD
			)


func _count_alive_neighbors(location: Vector2i) -> int:
	var count = 0

	for neighbor in NEIGHBORS:
		var neighbor_cell := location + neighbor
		var is_neighbor_outside_grid: bool = (
				neighbor_cell.x < 0
				or neighbor_cell.y < 0
				or neighbor_cell.x >= _grid_size.x
				or neighbor_cell.y >= _grid_size.y
		)

		if is_neighbor_outside_grid:
			continue

		if _map[neighbor_cell] == PlantState.ALIVE:
			count += 1

	return count


func update_grid() -> void:
	_map = _advance_simulation(_map)
	_paint_map()


func _advance_simulation(input_map: Dictionary[Vector2i, PlantState]) -> Dictionary[Vector2i, PlantState]:
	var new_map: Dictionary[Vector2i, PlantState] = { }

	for cell in input_map:
		var alive_count = _count_alive_neighbors(cell)

		if input_map[cell] == PlantState.ALIVE and alive_count > 2:
			new_map[cell] = PlantState.DEAD
		elif input_map[cell] == PlantState.DEAD and alive_count == 2:
			new_map[cell] = PlantState.ALIVE
		else:
			new_map[cell] = input_map[cell]

	return new_map


func _paint_map() -> void:
	for cell in _map:
		var flower_frame: int = PlantState.DEAD
		if _map[cell] == PlantState.ALIVE:
			flower_frame = randi_range(PlantState.ALIVE, 4)
		foliage_tile_map_layer.set_cell(cell, 0, Vector2i(flower_frame, 0))
