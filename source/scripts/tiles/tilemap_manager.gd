extends TileMapLayer
class_name TileMapManager

var units_on_grid = {} 

func _ready():
	# Example: Place all units that are already children of this map
	for child in get_children():
		if child is Unit:
			# Get the tile coordinate based on where you dropped them in the editor
			var tile_pos = local_to_map(child.position)
			place_unit(child, tile_pos)

func place_unit(unit: Unit, tile_coords: Vector2i):
	# map_to_local gives the center point of the isometric diamond
	unit.position = map_to_local(tile_coords)
	
	# Store the unit's position in our dictionary for gameplay logic later
	units_on_grid[tile_coords] = unit
	print("Placed ", unit.stats.job_name, " at grid ", tile_coords)
