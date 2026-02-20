extends Node3D

@onready var papiro_mesh = $mapa_menu
@onready var main_page = $MainPage
@onready var ajustes_page = $AjustesPage 
@onready var camera = $Camera3D
@onready var w_icon = $TextureRect 
@onready var luz_mesa = $TableLight

@export var textura_ajustes: Texture2D 
@export var textura_principal: Texture2D
@export var cena_ajustes: PackedScene  
@export var cena_principal: PackedScene 

var ja_subiu: bool = false

var volume: int = 100
var brilho: int = 100
var base_light_energy: float = 1.0 # 

var resolucoes = [Vector2i(1920, 1080), Vector2i(1600, 900), Vector2i(1366, 768), Vector2i(1280, 720)]
var res_idx: int = 0
var tela_cheia: bool = false

func _ready():
	if luz_mesa:
		base_light_energy = luz_mesa.light_energy 
		
	if w_icon:
		w_icon.scale = Vector2(1, 1)
		var tween = create_tween().set_loops()
		tween.tween_property(w_icon, "modulate:a", 0.3, 1.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(w_icon, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)

func _process(_delta):
	if Input.is_action_just_pressed("press_w") and not ja_subiu:
		ja_subiu = true 
		subir_camera()
		if w_icon:
			w_icon.hide()

func subir_camera():
	var tween = create_tween().set_parallel(true)
	var nova_posicao = Vector3(camera.position.x - 1, 3.2, camera.position.z)
	tween.tween_property(camera, "position", nova_posicao, 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera, "rotation_degrees", Vector3(-90, 90, 0), 1.2).set_trans(Tween.TRANS_SINE)

func ir_para_ajustes():
	main_page.visible = false 
	if ajustes_page:
		ajustes_page.visible = true # 
		
	var viewport = $mapa_menu/MapaNaMesa
	for child in viewport.get_children():
		child.queue_free()
	
	if cena_ajustes:
		var menu = cena_ajustes.instantiate()
		viewport.add_child(menu)
		call_deferred("atualizar_textos_ajustes")

func ir_para_principal():
	if ajustes_page:
		ajustes_page.visible = false
	main_page.visible = true 
	
	var viewport = $mapa_menu/MapaNaMesa
	for child in viewport.get_children():
		child.queue_free()
	
	if cena_principal:
		var menu = cena_principal.instantiate()
		viewport.add_child(menu)
		
func mudar_brilho(valor: int):
	# Clamp em 10 para nunca ficar 100% escuro
	brilho = clamp(brilho + valor, 10, 100)
	if luz_mesa:
		luz_mesa.light_energy = base_light_energy * (brilho / 100.0)
	atualizar_textos_ajustes()

func mudar_volume(valor: int):
	volume = clamp(volume + valor, 0, 100)
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus, volume == 0)
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(volume / 100.0))
	atualizar_textos_ajustes()

func mudar_resolucao():
	res_idx = (res_idx + 1) % resolucoes.size()
	DisplayServer.window_set_size(resolucoes[res_idx])
	atualizar_textos_ajustes()

func alternar_tela_cheia():
	tela_cheia = !tela_cheia
	if tela_cheia:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func atualizar_textos_ajustes():
	var viewport = $mapa_menu/MapaNaMesa

	if viewport.get_child_count() > 0:

		var menu_instanciado = viewport.get_child(viewport.get_child_count() - 1)

		var lbl_brilho = menu_instanciado.find_child("brilho_value", true, false)
		var lbl_volume = menu_instanciado.find_child("volume_value", true, false)
		var lbl_res = menu_instanciado.find_child("resolucao", true, false)

		print(lbl_brilho, lbl_volume, lbl_res)

		if lbl_brilho:
			lbl_brilho.text = str(brilho) + "%"

		if lbl_volume:
			lbl_volume.text = str(volume) + "%"

		if lbl_res:
			lbl_res.text = str(resolucoes[res_idx].x) + "x" + str(resolucoes[res_idx].y)

func _on_start_game_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_file("res://scenes/levels/tutorial.tscn")

func _on_ajustes_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ir_para_ajustes()

func _on_sair_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().quit()

func _on_plus_bright_input_event(_c, event, _p, _n, _s):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mudar_brilho(10)

func _on_minus_bright_input_event(_c, event, _p, _n, _s): # Nome conforme seu script anterior
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mudar_brilho(-10)

func _on_plus_volume_input_event(_c, event, _p, _n, _s):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mudar_volume(10)

func _on_minus_volume_input_event(_c, event, _p, _n, _s):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mudar_volume(-10)

func _on_resolution_input_event(_c, event, _p, _n, _s):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		res_idx = (res_idx + 1) % resolucoes.size()
		DisplayServer.window_set_size(resolucoes[res_idx])
		atualizar_textos_ajustes()

func _on_full_screen_input_event(_c, event, _p, _n, _s):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tela_cheia = !tela_cheia
		var modo = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if tela_cheia else DisplayServer.WINDOW_MODE_WINDOWED
		DisplayServer.window_set_mode(modo)

func _on_voltar_input_event(_c, event, _p, _n, _s):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ir_para_principal()

func _set_wobble(btn_node: Node, intensity: float) -> void:
	if btn_node and btn_node.material is ShaderMaterial:
		btn_node.material.set_shader_parameter("intensityX", intensity)
		btn_node.material.set_shader_parameter("intensityY", intensity)

func _set_btn_wobble(btn_name: String, intensity: float):
	var viewport = $mapa_menu/MapaNaMesa
	if viewport.get_child_count() > 0:
		var menu_atual = viewport.get_child(viewport.get_child_count() - 1)
		var btn = menu_atual.find_child(btn_name, true, false)
		_set_wobble(btn, intensity)

func _on_start_game_mouse_entered() -> void:
	_set_btn_wobble("btn_ajustes", 20.0) 

func _on_start_game_mouse_exited() -> void:
	_set_btn_wobble("btn_ajustes", 0.0)

func _on_ajustes_mouse_entered() -> void:
	_set_btn_wobble("btn_continuar", 20.0)

func _on_ajustes_mouse_exited() -> void:
	_set_btn_wobble("btn_continuar", 0.0)

func _on_credits_mouse_entered() -> void:
	_set_btn_wobble("btn_creditos", 20.0)

func _on_credits_mouse_exited() -> void:
	_set_btn_wobble("btn_creditos", 0.0)

func _on_sair_mouse_entered() -> void:
	_set_btn_wobble("btn_sair", 20.0)

func _on_sair_mouse_exited() -> void:
	_set_btn_wobble("btn_sair", 0.0)
