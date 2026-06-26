extends Node2D

@export var treasure_scene: PackedScene

enum CellType { WALL, FLOOR }

const MAP_SIZE := Vector2i(80, 45)
const CELL_SIZE := 64
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

var minimum_exit_distance := 10
var minimum_cavern_size := 50
var maximum_treasure := 10

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
@onready var miner: CharacterBody2D = %Miner
@onready var exit: Area2D = %Exit


func _ready() -> void:
	generate_new_dungeon()


func generate_new_dungeon() -> void:
	_map = _generate_random_map()

	for step in step_count:
		if step_time > 0:
			_paint_map()
			await get_tree().create_timer(step_time).timeout

		_map = _advance_simulation()

	_remove_small_caverns()
	_paint_map()
	_position_start_and_exit()
	_add_treasure()


func _generate_random_map() -> Dictionary[Vector2i, CellType]:
	var map: Dictionary[Vector2i, CellType] = { }
	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			map[Vector2i(x, y)] = CellType.WALL if randf() < wall_chance else CellType.FLOOR
	return map


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


func _remove_small_caverns():
	var caverns = _find_caverns()

	for cavern_index in caverns:
		if caverns[cavern_index].size() < minimum_cavern_size:
			for cell in caverns[cavern_index]:
				_map[cell] = CellType.WALL


func _find_caverns() -> Dictionary:
	var caverns = { }
	var map_copy = _map.duplicate(true)

	# We assign a unique id to each cavern to differentiate them.
	var cavern_index := 2

	for cell in map_copy:
		if not map_copy[cell] == CellType.FLOOR:
			continue
		caverns[cavern_index] = _assign_cavern(cell, cavern_index, map_copy)
		cavern_index += 1

	return caverns


func _assign_cavern(cell: Vector2, index: int, map: Dictionary) -> Array:
	var check_cells = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

	var queue := []
	var cavern_cells := []
	queue.append(cell)

	while queue:
		var current = queue.pop_front()

		if not map.has(current):
			continue

		if not map[current] == CellType.FLOOR:
			continue

		map[current] = index
		cavern_cells.append(current)

		for direction in check_cells:
			var neighbor = current + direction
			queue.append(neighbor)

	return cavern_cells


func _paint_map() -> void:
	for cell in _map:
		dungeon_tile_map_layer.set_cell(cell, _map[cell], Vector2i.ZERO)
	var all_cells = dungeon_tile_map_layer.get_used_cells_by_id(CellType.FLOOR)
	dungeon_tile_map_layer.set_cells_terrain_connect(all_cells, 0, 0, false)


func _position_start_and_exit() -> void:
	var floor_cells = dungeon_tile_map_layer.get_used_cells_by_id(CellType.FLOOR)
	if floor_cells.is_empty():
		return

	var miner_cell := Vector2.ZERO
	var exit_cell := Vector2.ZERO

	floor_cells.shuffle()

	while floor_cells:
		var cell = floor_cells.pop_back()

		if _count_floor_neighbors(cell) < 8:
			continue

		miner_cell = cell
		break

	while floor_cells:
		var cell: Vector2 = floor_cells.pop_back()

		if cell.distance_to(miner_cell) < minimum_exit_distance:
			continue

		if _count_floor_neighbors(cell) < 8:
			continue

		exit_cell = cell
		break

	miner.position = miner_cell * CELL_SIZE
	exit.position = exit_cell * CELL_SIZE


func _add_treasure() -> void:
	for treasure in get_tree().get_nodes_in_group("treasure"):
		treasure.queue_free()

	var floor_cells = dungeon_tile_map_layer.get_used_cells_by_id(CellType.FLOOR)
	var treasures_placed := 0

	var corner_subtiles := [Vector2i(0, 0), Vector2i(0, 2), Vector2i(2, 0), Vector2i(2, 2)]

	floor_cells.shuffle()

	while treasures_placed < maximum_treasure and floor_cells:
		var cell = floor_cells.pop_back()

		var subtile = dungeon_tile_map_layer.get_cell_atlas_coords(Vector2i(cell.x, cell.y))
		if not corner_subtiles.has(subtile):
			continue

		var treasure = treasure_scene.instantiate()
		var offset = (Vector2.ONE - Vector2(subtile)) * CELL_SIZE / 2
		treasure.position = Vector2(cell) * CELL_SIZE + offset
		add_child(treasure)
		treasures_placed += 1


func _count_floor_neighbors(location: Vector2i) -> int:
	var count = 0
	for neighbor in NEIGHBORS:
		var check_location := location + neighbor
		if not _map.has(check_location):
			continue

		if _map[check_location] == CellType.FLOOR:
			count += 1

	return count


func remove_walls(global_positions: Array[Vector2]) -> void:
	for pos in global_positions:
		var cell = dungeon_tile_map_layer.local_to_map(pos)

		if dungeon_tile_map_layer.get_cell_source_id(cell) == CellType.FLOOR:
			continue

		dungeon_tile_map_layer.set_cell(cell, CellType.FLOOR, Vector2i.ZERO)
		var surrounding_cells := dungeon_tile_map_layer.get_surrounding_cells(cell)
		var surrounding_floor_cells: Array[Vector2i] = []
		for surrounding_cell in surrounding_cells:
			if dungeon_tile_map_layer.get_cell_source_id(surrounding_cell) == CellType.FLOOR:
				surrounding_floor_cells.push_back(surrounding_cell)
		dungeon_tile_map_layer.set_cells_terrain_connect(surrounding_floor_cells, 0, 0, false)


# We use the setters below to update values when changing the sliders.
func set_minimum_exit_distance(value: int) -> void:
	minimum_exit_distance = value


func set_minimum_cavern_size(value: int) -> void:
	minimum_cavern_size = value


func set_maximum_treasure(value: int) -> void:
	maximum_treasure = value


func set_wall_chance(value: float) -> void:
	wall_chance = value


func set_wall_conversion(value: int) -> void:
	wall_conversion = value


func set_floor_conversion(value: int) -> void:
	floor_conversion = value


func set_step_count(value: int) -> void:
	step_count = value


func set_step_time(value: float) -> void:
	step_time = value
