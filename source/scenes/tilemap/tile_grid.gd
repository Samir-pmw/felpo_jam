extends Node3D

@export var tile_scene: PackedScene
@export var grid_columns: int = 10
@export var grid_rows: int = 10
@export var tile_size: float = 1.5      
@export var min_elevation: float = 0.0
@export var max_elevation: float = 1.5

func _ready() -> void:
	generate_grid()

func generate_grid() -> void:
	for row in range(grid_rows):
		for col in range(grid_columns):
			var tile = tile_scene.instantiate()
			add_child(tile)

			tile.position = Vector3(
				col * tile_size,
				0.0,
				row * tile_size
			)

			var elevation = randf_range(min_elevation, max_elevation)
			tile.set_elevation(elevation)
