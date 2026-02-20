extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var tipo_fase: String = ""

func fase(imagem: Texture2D, tipo: String):
	texture_normal = imagem
	tipo_fase = tipo

func _on_pressed():
	get_tree().change_scene_to_file("") #LINK DA FASE VAI ENTRAR AQUI
	
