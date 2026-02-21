extends Control

@export var ability_button_scene = preload("res://scenes/combatui/ability_button.tscn")

@onready var mana_bar = $ManaBar
@onready var info_panel = $InfoPanel
@onready var job_label = $InfoPanel/VBoxContainer/JobNameLabel
@onready var hp_label = $InfoPanel/VBoxContainer/StatsHBox/HPLabel
@onready var move_label = $InfoPanel/VBoxContainer/StatsHBox/MoveLabel
@onready var ability_list = $InfoPanel/VBoxContainer/AbilityList

func _ready():
	mana_bar.value = 10
	info_panel.visible = false
	
func atualizar_painel_personagem(unit: UnitData):
	info_panel.visible = true
	
	job_label.text = unit.job_name
	hp_label.text = "HP: " + str(unit.max_hp)
	move_label.text = "Move: " + str(unit.move_range)
	
	for child in ability_list.get_children():
		child.queue_free()
		
	for ability in unit.abilities:
		var novo_botao = ability_button_scene.instantiate()
		ability_list.add_child(novo_botao)
		novo_botao.setup(ability)
		
