extends Node3D

var _floor_ready: bool = false

func _ready() -> void:
	$SubViewport.use_hdr_2d = false
	$SubViewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED

	# Show the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var viewport := $SubViewport
	var tex_rect := $CanvasLayer/OutlineShader
	tex_rect.texture = viewport.get_texture()
	var mat := tex_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("viewport_texture", viewport.get_texture())

	_setup_outline()

func _process(_delta: float) -> void:
	if not _floor_ready:
		_floor_ready = true
		_setup_floor()
		return

	_do_raycast()

func _do_raycast() -> void:
	var viewport    := $SubViewport
	var camera      := $SubViewport/Camera3D
	var grid        := $SubViewport/TileGrid

	var vp_size:   Vector2 = viewport.size
	var tex_rect           := $CanvasLayer/OutlineShader
	var rect_size: Vector2 = tex_rect.size
	var mouse_pos: Vector2 = tex_rect.get_local_mouse_position()

	var uv: Vector2 = mouse_pos / rect_size
	if uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0:
		grid.try_hover(null)
		return

	var vp_mouse: Vector2 = uv * vp_size

	var ray_origin: Vector3 = camera.project_ray_origin(vp_mouse)
	var ray_dir:    Vector3 = camera.project_ray_normal(vp_mouse)
	var ray_end:    Vector3 = ray_origin + ray_dir * 1000.0

	# ✅ Explicit types fix the inference errors
	var space: PhysicsDirectSpaceState3D = viewport.find_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = false
	var result: Dictionary = space.intersect_ray(query)

	if result.is_empty():
		grid.try_hover(null)
		return

	var hit_node: Node = result["collider"]
	var tile: Node3D   = _find_tile_parent(hit_node, grid)
	grid.try_hover(tile)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var grid := $SubViewport/TileGrid
			# Select whatever is currently hovered
			grid.try_select(grid._hovered_tile)

func _find_tile_parent(node: Node, grid: Node) -> Node3D:
	# Walk up until we find a direct child of TileGrid
	var current: Node = node
	while current != null:
		if current.get_parent() == grid:
			return current as Node3D
		current = current.get_parent()
	return null

func _setup_outline() -> void:
	var quad := MeshInstance3D.new()
	var mesh  := QuadMesh.new()
	mesh.size = Vector2(2.0, 2.0)
	quad.mesh = mesh
	quad.position         = Vector3(0.0, 0.0, -0.001)
	quad.cast_shadow      = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	$SubViewport/Camera3D.add_child(quad)
	var outline_mat := ShaderMaterial.new()
	outline_mat.shader = load("res://assets/shaders/outline.gdshader")
	quad.material_override = outline_mat

func _setup_floor() -> void:
	var grid        := $SubViewport/TileGrid
	var col_spacing: float = grid._col_spacing
	var row_spacing: float = grid._row_spacing
	var base_y:      float = grid._base_y

	if col_spacing <= 0.01:
		_floor_ready = false
		return

	var floor_w: float = grid.grid_columns * col_spacing * 1.8
	var floor_h: float = grid.grid_rows    * row_spacing * 1.8
	var cx:      float = (grid.grid_columns - 1) * col_spacing / 2.0
	var cz:      float = (grid.grid_rows - 1)    * row_spacing / 2.0

	var plane      := MeshInstance3D.new()
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(floor_w, floor_h)
	plane.mesh       = plane_mesh
	plane.position   = Vector3(cx, base_y - 0.02, cz)
	plane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var floor_mat := ShaderMaterial.new()
	floor_mat.shader = load("res://assets/shaders/checkered_floor.gdshader")
	floor_mat.set_shader_parameter("color_a",   Color(0.17, 0.17, 0.19))
	floor_mat.set_shader_parameter("color_b",   Color(0.22, 0.22, 0.25))
	floor_mat.set_shader_parameter("tile_size", col_spacing)
	plane.material_override = floor_mat

	$SubViewport.add_child(plane)

func _unhandled_input(event: InputEvent) -> void:
	$SubViewport.push_input(event)
