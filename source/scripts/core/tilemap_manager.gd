extends TileMapLayer
class_name LevelGrid

@export_group("Enemy Config")
@export var enemy_pool: Array[UnitData]
@export var enemy_count: int = 5

var unit_scene: PackedScene = preload("res://scenes/units/unit.tscn")
var units_on_grid: Dictionary = {}

func _ready():
	var screen_center = get_viewport_rect().size / 2
	position = screen_center

	units_on_grid.clear()
	spawn_players()
	spawn_enemies(enemy_count)

	queue_redraw()

func spawn_players():
	var center_grid = Vector2i(0, 0)
	var offsets = [
		Vector2i(0,0),
		Vector2i(2,0),
		Vector2i(-2,0),
		Vector2i(0,2),
		Vector2i(0,-2)
	]

	var player_index = 0

	for child in get_children():
		if child is Unit and child.stats and not child.stats.is_enemy:
			var target_tile = center_grid + offsets[player_index % offsets.size()]

			child.position = map_to_local(target_tile)
			child.add_to_group("players")

			units_on_grid[target_tile] = child
			player_index += 1

func spawn_enemies(count: int):
	if enemy_pool.is_empty():
		return

	var valid_tiles = get_used_cells()
	valid_tiles.shuffle()

	var spawned = 0

	for cell in valid_tiles:
		if spawned >= count:
			break

		if not units_on_grid.has(cell):
			var enemy = unit_scene.instantiate()
			enemy.stats = enemy_pool.pick_random()
			add_child(enemy)

			enemy.position = map_to_local(cell)
			units_on_grid[cell] = enemy

			spawned += 1

	queue_redraw()

# TODO: Remover (Debug)
func _draw():
	draw_line(Vector2(-1000, 0), Vector2(1000, 0), Color.RED, 5.0)

	var debug_color = Color(1, 0.5, 0, 0.8)
	var cells = get_used_cells()

	if cells.is_empty():
		print("DEBUG ERROR: No tiles painted!")

	for cell in cells:
		var pos = map_to_local(cell)
		draw_circle(pos, 8.0, debug_color)
