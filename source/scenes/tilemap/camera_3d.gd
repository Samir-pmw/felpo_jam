extends Camera3D

# --- Grid reference ---
@export var grid_columns: int = 10
@export var grid_rows: int = 10
@export var hex_radius: float = 1.0

# --- Feel ---
@export var pan_speed: float = 10.0
@export var zoom_speed: float = 6.0
@export var rotate_speed: float = 0.005
@export var smooth_speed: float = 8.0

# --- Limits ---
@export var min_zoom: float = 5.0
@export var max_zoom: float = 22.0
@export var pitch_min_deg: float = -75.0
@export var pitch_max_deg: float = -20.0

# --- Internal state (NO deg_to_rad here — moved to _ready) ---
var _yaw: float = 0.0
var _pitch: float = 0.0
var _zoom: float = 14.0
var _target: Vector3

var _smooth_yaw: float = 0.0
var _smooth_pitch: float = 0.0
var _smooth_zoom: float = 14.0
var _smooth_target: Vector3

var _rotating: bool = false

func _ready() -> void:
	_pitch        = deg_to_rad(-50.0)
	_smooth_pitch = deg_to_rad(-50.0)

	var grid = get_parent().get_node_or_null("TileGrid")
	if grid:
		grid_columns = grid.grid_columns
		grid_rows    = grid.grid_rows
		hex_radius   = grid.hex_radius  

	var col_spacing = hex_radius * sqrt(3.0)
	var row_spacing = hex_radius * 1.5
	_target = Vector3(
		(grid_columns - 1) * col_spacing / 2.0,
		0.0,
		(grid_rows - 1) * row_spacing / 2.0
	)
	_smooth_target = _target
	_smooth_yaw    = _yaw
	_smooth_zoom   = _zoom
	_apply_transform_direct()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_zoom = clamp(_zoom - zoom_speed * 0.4, min_zoom, max_zoom)
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom = clamp(_zoom + zoom_speed * 0.4, min_zoom, max_zoom)
			MOUSE_BUTTON_RIGHT:
				_rotating = event.pressed

	if event is InputEventMouseMotion and _rotating:
		_yaw   -= event.relative.x * rotate_speed
		_pitch  = clamp(
			_pitch - event.relative.y * rotate_speed,
			deg_to_rad(pitch_min_deg),
			deg_to_rad(pitch_max_deg)
		)

func _process(delta: float) -> void:
	var move := Vector2.ZERO
	if Input.is_action_pressed("ui_right"): move.x += 1
	if Input.is_action_pressed("ui_left"):  move.x -= 1
	if Input.is_action_pressed("ui_down"):  move.y += 1
	if Input.is_action_pressed("ui_up"):    move.y -= 1

	if move != Vector2.ZERO:
		var forward = Vector3(sin(_smooth_yaw), 0.0, cos(_smooth_yaw))
		var right   = Vector3(cos(_smooth_yaw), 0.0, -sin(_smooth_yaw))
		_target += (right * move.x + forward * move.y) * pan_speed * delta
		_clamp_target()

	var t = clamp(smooth_speed * delta, 0.0, 1.0)
	_smooth_yaw    = lerp_angle(_smooth_yaw, _yaw, t)
	_smooth_pitch  = lerp(_smooth_pitch,     _pitch, t)
	_smooth_zoom   = lerp(_smooth_zoom,      _zoom, t)
	_smooth_target = _smooth_target.lerp(_target, t)

	_apply_transform_smooth()

func _apply_transform_smooth() -> void:
	var offset = Vector3(
		_smooth_zoom * cos(_smooth_pitch) * sin(_smooth_yaw),
		_smooth_zoom * -sin(_smooth_pitch),
		_smooth_zoom * cos(_smooth_pitch) * cos(_smooth_yaw)
	)
	position = _smooth_target + offset
	look_at(_smooth_target, Vector3.UP)

func _apply_transform_direct() -> void:
	var offset = Vector3(
		_zoom * cos(_pitch) * sin(_yaw),
		_zoom * -sin(_pitch),
		_zoom * cos(_pitch) * cos(_yaw)
	)
	position = _target + offset
	look_at(_target, Vector3.UP)

func _clamp_target() -> void:
	var col_spacing = hex_radius * sqrt(3.0)
	var row_spacing = hex_radius * 1.5
	var max_x = (grid_columns - 1) * col_spacing
	var max_z = (grid_rows - 1) * row_spacing
	_target.x = clamp(_target.x, -col_spacing, max_x + col_spacing)
	_target.z = clamp(_target.z, -row_spacing, max_z + row_spacing)
