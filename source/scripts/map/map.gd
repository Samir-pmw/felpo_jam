extends Node2D

@export var preset_botao = preload("res://scenes/map/botao_fase.tscn")

@export var imagens: Array[Texture2D]
var tipos_fases = ["Combate", "Tesouro", "Fogueira", "Loja", "Puzzle"]

func _ready():
	randomize()
	criar_mapa()
	
func criar_mapa():
	for marcador in $Fases.get_children():
		var novo_botao = preset_botao.instantiate()
		var numero = randi_range(0, imagens.size() - 1)
		novo_botao.fase(imagens[numero], tipos_fases[numero])
		novo_botao.global_position = marcador.global_position
		add_child(novo_botao)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
