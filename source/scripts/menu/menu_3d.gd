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

# --- VARIÁVEIS DE CONFIGURAÇÃO ---
var volume: int = 100
var brilho: int = 100
var base_light_energy: float = 1.0 # Guarda a energia original da luz

var resolucoes = [Vector2i(1920, 1080), Vector2i(1600, 900), Vector2i(1366, 768), Vector2i(1280, 720)]
var res_idx: int = 0
var tela_cheia: bool = false

func _ready():
	if luz_mesa:
		base_light_energy = luz_mesa.light_energy # Salva a luz padrão no início
		
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

# --- TRANSIÇÕES DE MENU ---

func ir_para_ajustes():
	main_page.visible = false 
	if ajustes_page:
		ajustes_page.visible = true # Mostra os hitboxes de ajustes
		
	var viewport = $mapa_menu/MapaNaMesa
	for child in viewport.get_children():
		child.queue_free()
	
	if cena_ajustes:
		var menu = cena_ajustes.instantiate()
		viewport.add_child(menu)
		# Espera um frame para os nós carregarem, depois atualiza os textos
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

# --- FUNÇÕES DE LÓGICA DAS CONFIGURAÇÕES ---

func mudar_brilho(valor: int):
	print("Tentando abaixar 1")	
	
	brilho = clamp(brilho + valor, 0, 100)
	if luz_mesa:
		print("Tentando abaixar 2")	
		luz_mesa.light_energy = base_light_energy * (brilho / 100.0)
	print("Tentando abaixar 3")	
	atualizar_textos_ajustes()

func mudar_volume(valor: int):
	volume = clamp(volume + valor, 0, 100)
	# O Godot usa decibéis. Converter escala linear (0-1) para DB:
	var master_bus = AudioServer.get_bus_index("Master")
	if volume == 0:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
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

# --- ATUALIZAÇÃO DA UI 2D ---
func atualizar_textos_ajustes():
	var viewport = $mapa_menu/MapaNaMesa
	if viewport.get_child_count() > 0:
		var menu = viewport.get_child(0)
		
		# IMPORTANTE: Coloque os nomes exatos das Labels do seu menu_ajustes.tscn aqui
		var lbl_brilho = menu.get_node_or_null("lbl_brilho_valor") 
		var lbl_volume = menu.get_node_or_null("lbl_volume_valor")
		var lbl_resolucao = menu.get_node_or_null("resolucao") 
		
		if lbl_brilho: lbl_brilho.text = str(brilho)
		if lbl_volume: lbl_volume.text = str(volume)
		if lbl_resolucao: lbl_resolucao.text = str(resolucoes[res_idx].x) + " X " + str(resolucoes[res_idx].y)


# --- SINAIS DE INPUT (HITBOXES) ---

# Sinais Antigos do Menu Principal
func _on_start_game_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_file("res://scenes/levels/tutorial.tscn")

func _on_ajustes_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ir_para_ajustes()

func _on_sair_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().quit()

func _on_vol_mais_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mudar_volume(5) # Altera de 5 em 5. Mude se quiser.

func _on_vol_menos_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mudar_volume(-5)

func _on_brilho_mais_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mudar_brilho(1) # Muda 1% conforme pediu

func _on_minus_bright_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mudar_brilho(-1)

func _on_resolucao_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mudar_resolucao()

func _on_tela_cheia_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		alternar_tela_cheia()

func _on_voltar_input_event(_c, event, _p, _n, _s) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ir_para_principal()


func _set_wobble(btn_node: Node, intensity: float) -> void:
	if btn_node and btn_node.material is ShaderMaterial:
		btn_node.material.set_shader_parameter("intensityX", intensity)
		btn_node.material.set_shader_parameter("intensityY", intensity)

func _on_start_game_mouse_entered() -> void:
	_set_wobble($mapa_menu/MapaNaMesa/Control/btn_ajustes, 20.0)

func _on_start_game_mouse_exited() -> void:
	_set_wobble($mapa_menu/MapaNaMesa/Control/btn_ajustes, 0.0)

func _on_ajustes_mouse_entered() -> void:
	_set_wobble($mapa_menu/MapaNaMesa/Control/btn_continuar, 20.0)

func _on_ajustes_mouse_exited() -> void:
	_set_wobble($mapa_menu/MapaNaMesa/Control/btn_continuar, 0.0)

func _on_credits_mouse_entered() -> void:
	_set_wobble($mapa_menu/MapaNaMesa/Control/btn_creditos, 20.0)

func _on_credits_mouse_exited() -> void:
	_set_wobble($mapa_menu/MapaNaMesa/Control/btn_creditos, 0.0)

func _on_sair_mouse_entered() -> void:
	_set_wobble($mapa_menu/MapaNaMesa/Control/btn_sair, 20.0)

func _on_sair_mouse_exited() -> void:
	_set_wobble($mapa_menu/MapaNaMesa/Control/btn_sair, 0.0)
