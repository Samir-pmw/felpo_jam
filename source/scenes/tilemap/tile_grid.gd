extends Node3D

@export var tile_scene: PackedScene = preload("res://scenes/tilemap/tile.tscn")
@export var grid_columns: int = 16
@export var grid_rows: int = 16
@export var min_elevation: float = 0.2
@export var max_elevation: float = 2.5
@export var spacing_bias: float = 0.0

var _hovered_tile:    Node3D = null
var _selected_tile:   Node3D = null

# Fraction of the map radius that stays FLAT at the center (0.0–1.0)
@export var flat_center_radius: float = 0.35
# How steeply the edges rise after the flat zone
@export var island_falloff: float = 3.0
# Max height step between neighbours
@export var max_neighbour_diff: float = 0.35

var _col_spacing: float = 1.0
var _row_spacing: float = 1.0
var hex_radius:   float = 1.0
var _base_y:      float = 0.0

func _ready() -> void:
	_measure_spacing_sync()
	generate_grid()
	
# Add this function
func try_hover(tile: Node3D) -> void:
	if tile == _hovered_tile:
		return
	if _hovered_tile:
		_hovered_tile.set_hovered(false)
	_hovered_tile = tile
	if _hovered_tile:
		_hovered_tile.set_hovered(true)

func try_select(tile: Node3D) -> void:
	if tile == _selected_tile:
		return
	# Deselect old
	if _selected_tile:
		_selected_tile.set_selected(false)
		# Restore hover if it's still being hovered
		if _selected_tile == _hovered_tile:
			_selected_tile.set_hovered(true)
	_selected_tile = tile
	if _selected_tile:
		_selected_tile.set_selected(true)

func _measure_spacing_sync() -> void:
	var sample: Node3D = tile_scene.instantiate()
	sample.position = Vector3(-9999, -9999, -9999)
	add_child(sample)
	var mi := _find_mesh(sample)
	if mi and mi.mesh:
		var aabb: AABB = mi.mesh.get_aabb()
		var wx: float = abs(aabb.size.x)
		var wz: float = abs(aabb.size.z)
		_col_spacing = wx + spacing_bias
		_row_spacing = wz * 0.75 + spacing_bias
		hex_radius   = max(wx, wz) / 2.0
		print("TileGrid → col:", _col_spacing, " row:", _row_spacing, " r:", hex_radius)
	else:
		push_warning("TileGrid: MeshInstance3D not found, using defaults.")
	sample.queue_free()

func generate_grid() -> void:
	var elevations: Array[float] = []
	elevations.resize(grid_rows * grid_columns)

	var center_col: float = (grid_columns - 1) / 2.0
	var center_row: float = (grid_rows - 1)    / 2.0

	for row in range(grid_rows):
		for col in range(grid_columns):
			var dc: float   = (col - center_col) / center_col
			var dr: float   = (row - center_row) / center_row
			# Normalized distance 0.0 (center) → 1.0 (corner)
			var dist: float = clamp(sqrt(dc * dc + dr * dr) / sqrt(2.0), 0.0, 1.0)

			# Subtract the flat zone — anything inside it stays 0
			var edge_dist: float = max(0.0, dist - flat_center_radius) / (1.0 - flat_center_radius)
			var island_bias: float = pow(edge_dist, island_falloff)

			# Small noise so the flat center isn't perfectly uniform
			var noise: float = randf_range(-0.08, 0.08)
			var raw: float   = lerp(min_elevation, max_elevation,
									clamp(island_bias + noise, 0.0, 1.0))

			elevations[row * grid_columns + col] = raw

	# Smooth passes — enforce max neighbour difference
	var max_diff: float = max_neighbour_diff * max_elevation
	for _pass in range(4):
		for row in range(grid_rows):
			for col in range(grid_columns):
				var idx: int    = row * grid_columns + col
				var avg: float  = _neighbour_avg(elevations, row, col)
				elevations[idx] = clamp(elevations[idx], avg - max_diff, avg + max_diff)

	_base_y = elevations.min()

	var tile_idx: int = 0
	for row in range(grid_rows):
		for col in range(grid_columns):
			var tile: Node3D = tile_scene.instantiate()
			add_child(tile)
			var row_offset: float = _col_spacing * 0.5 if row % 2 == 1 else 0.0
			tile.position = Vector3(
				col * _col_spacing + row_offset,
				_base_y,
				row * _row_spacing
			)
			if tile.has_method("set_elevation"):
				tile.set_elevation(elevations[tile_idx], _base_y)
			tile_idx += 1

func _neighbour_avg(elevations: Array[float], row: int, col: int) -> float:
	var neighbours: Array[Vector2i] = [
		Vector2i(col - 1, row), Vector2i(col + 1, row),
		Vector2i(col, row - 1), Vector2i(col, row + 1),
	]
	var offset: int = 1 if row % 2 == 1 else -1
	neighbours.append(Vector2i(col + offset, row - 1))
	neighbours.append(Vector2i(col + offset, row + 1))

	var sum: float = 0.0
	var count: int = 0
	for n in neighbours:
		if n.x >= 0 and n.x < grid_columns and n.y >= 0 and n.y < grid_rows:
			sum   += elevations[n.y * grid_columns + n.x]
			count += 1
	return sum / count if count > 0 else elevations[row * grid_columns + col]

func _find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result := _find_mesh(child)
		if result:
			return result
	return null
