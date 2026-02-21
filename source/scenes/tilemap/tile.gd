extends Node3D

const HOVER_LIFT:     float = 0.12
const SELECT_LIFT:    float = 0.28   # selected rests higher
const HIGHLIGHT_SPEED: float = 14.0

# Pop animation when selected
const POP_LIFT:       float = 0.45   # peak of the pop
const POP_SPEED:      float = 18.0

enum State { NORMAL, HOVERED, SELECTED }

var _base_position:  Vector3
var _current_lift:   float = 0.0
var _state:          State = State.NORMAL

# Pop animation
var _pop_phase:      float = 0.0   # 0.0 = idle, goes to 1.0 and back
var _popping:        bool  = false

var _hover_mat:   ShaderMaterial = null
var _select_mat:  ShaderMaterial = null

@onready var _top:  Node3D = $Top
@onready var _stem: Node3D = $Stem

func _ready() -> void:
	_base_position = position

	_hover_mat = ShaderMaterial.new()
	_hover_mat.shader = load("res://assets/shaders/tile_highlight.gdshader")
	_hover_mat.set_shader_parameter("albedo",        Color(1.0, 1.0, 1.0, 1.0))
	_hover_mat.set_shader_parameter("outline_width", 4.0)

	_select_mat = ShaderMaterial.new()
	_select_mat.shader = load("res://assets/shaders/tile_highlight.gdshader")
	_select_mat.set_shader_parameter("albedo",        Color(1.0, 0.85, 0.2, 1.0))  # gold
	_select_mat.set_shader_parameter("outline_width", 5.5)

func _process(delta: float) -> void:
	# --- Pop animation ---
	if _popping:
		_pop_phase += POP_SPEED * delta
		if _pop_phase >= PI:
			_pop_phase = 0.0
			_popping   = false

	var pop_extra: float = 0.0
	if _popping:
		# sin curve: goes up then back down to resting lift
		pop_extra = sin(_pop_phase) * (POP_LIFT - _get_target_lift())

	# --- Smooth lift ---
	var target: float = _get_target_lift() + pop_extra
	_current_lift = lerp(_current_lift, target, HIGHLIGHT_SPEED * delta)
	position = _base_position + Vector3(0.0, _current_lift, 0.0)

func _get_target_lift() -> float:
	match _state:
		State.HOVERED:  return HOVER_LIFT
		State.SELECTED: return SELECT_LIFT
		_:              return 0.0

func set_elevation(elevation: float, base_y: float) -> void:
	var column_height: float = elevation - base_y
	var stem_mi        := _find_mesh(_stem)
	var stem_natural_h: float = 1.0
	if stem_mi and stem_mi.mesh:
		stem_natural_h = abs(stem_mi.mesh.get_aabb().size.y)

	var stem_scale: float = max(column_height / stem_natural_h, 1.0)
	_stem.scale.y    = stem_scale
	_stem.position.y = 0.0
	_top.scale.y     = 1.0
	_top.position.y  = stem_natural_h * stem_scale

	position.y     = base_y
	_base_position = position

func set_hovered(on: bool) -> void:
	if _state == State.SELECTED:
		return  # selected takes priority
	var new_state: State = State.HOVERED if on else State.NORMAL
	if _state == new_state:
		return
	_state = new_state
	_apply_outline()

func set_selected(on: bool) -> void:
	var new_state: State = State.SELECTED if on else State.NORMAL
	if _state == new_state:
		return
	_state = new_state
	if on:
		_popping = true
		_pop_phase = 0.0
	_apply_outline()

func _apply_outline() -> void:
	var mat: ShaderMaterial = null
	match _state:
		State.HOVERED:  mat = _hover_mat
		State.SELECTED: mat = _select_mat
		State.NORMAL:   mat = null

	_set_outline(_find_mesh(_top),  mat)
	_set_outline(_find_mesh(_stem), mat)

func _set_outline(mi: MeshInstance3D, mat: ShaderMaterial) -> void:
	if mi == null:
		return
	if mat != null:
		var base: Material = mi.get_active_material(0)
		if base:
			var unique: Material = base.duplicate()
			unique.next_pass = mat
			mi.set_surface_override_material(0, unique)
		else:
			mi.set_surface_override_material(0, mat)
	else:
		mi.set_surface_override_material(0, null)

func _find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result := _find_mesh(child)
		if result:
			return result
	return null
