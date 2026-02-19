extends Camera2D

@export var tilemap: TileMapLayer
var dragging: bool = false

func _ready():
	if not tilemap:
		for sibling in get_parent().get_children():
			if sibling is TileMapLayer:
				tilemap = sibling
				break
	
	global_position = get_viewport_rect().size / 2

func _input(event):
	if not tilemap: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	
	if event is InputEventMouseMotion and dragging:
		global_position -= event.relative

func center_on_tilemap():
	var bounds = tilemap.get_used_rect()
	var center_grid_coord = Vector2i(
		bounds.position.x + bounds.size.x / 2,
		bounds.position.y + bounds.size.y / 2
	)
	
	global_position = tilemap.map_to_local(center_grid_coord)
