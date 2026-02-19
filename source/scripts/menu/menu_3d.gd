extends Node3D

@onready var papiro_mesh = $mapa_menu
@onready var main_page = $MainPage
@onready var camera = $Camera3D
@onready var w_icon = $TextureRect 

@export var textura_ajustes: Texture2D 
@export var textura_principal: Texture2D

var ja_subiu: bool = false

func _ready():
	if w_icon:
		# Reset de escala para garantir que não cresça
		w_icon.scale = Vector2(1, 1)
		var tween = create_tween().set_loops()
		tween.tween_property(w_icon, "modulate:a", 0.3, 1.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(w_icon, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)

func _process(_delta):
	# 2. Só deixa apertar se ainda não subiu
	if Input.is_action_just_pressed("press_w") and not ja_subiu:
		ja_subiu = true # Bloqueia futuras execuções
		subir_camera()
		if w_icon:
			w_icon.hide()

func subir_camera():
	var tween = create_tween().set_parallel(true)
	
	var nova_posicao = Vector3(
		camera.position.x - 1,      
		3.5,                  
		camera.position.z 
	)
	
	tween.tween_property(camera, "position", nova_posicao, 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera, "rotation_degrees", Vector3(-90, 90, 0), 1.2).set_trans(Tween.TRANS_SINE)
	
func _on_start_game_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_tree().change_scene_to_file("res://scenes/levels/tutorial.tscn")

func _on_ajustes_input_event(_cam, event, _pos, _norm, _shape) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ir_para_ajustes()

func ir_para_ajustes():
	main_page.visible = false 
	
	var mat = papiro_mesh.get_active_material(0) as StandardMaterial3D
	if mat:
		mat.albedo_texture = textura_ajustes
	
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector3(camera.position.x, 5.0, camera.position.z), 0.8).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(camera, "rotation_degrees", Vector3(-90, 90, 0), 0.8)
