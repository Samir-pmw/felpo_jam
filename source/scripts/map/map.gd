extends Node2D

@export var preset_botao = preload("res://scenes/map/botao_fase.tscn")

@export var fases: Array[FaseData] = []
		
func _ready():
	fases_da_pasta()
	randomize()
	criar_mapa()

func fases_da_pasta():
	var path = "res://resources/fases/"
	var arquivos = DirAccess.get_files_at(path)
	for nome_arquivo in arquivos:
		var recurso = load(path+nome_arquivo)
		fases.append(recurso)
		
func criar_mapa():
	var opcao_fases: Array[FaseData] = []
	var marcador = $Fases.get_children()
	for i in fases:
		for j in range(i.limite):
			opcao_fases.append(i)
	opcao_fases.shuffle()
	
	for i in range(marcador.size()):
		var novo_botao = preset_botao.instantiate()
		var dados_fase = opcao_fases[i]
		novo_botao.global_position = marcador[i].global_position
		novo_botao.fase(dados_fase)
		add_child(novo_botao)
