extends TextureButton

var dados: FaseData

func fase(p_dados: FaseData):
	dados = p_dados
	texture_normal = dados.textura
	var limite_ap = dados.limite

func _on_pressed():
	get_tree().change_scene_to_file("") #LINK DA FASE VAI ENTRAR AQUI
	
