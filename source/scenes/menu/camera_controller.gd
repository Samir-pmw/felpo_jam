extends Camera3D
class_name CameraController

var movendo: bool = false

func subir() -> void:
	if movendo:
		return
		
	movendo = true
	var tween = create_tween().set_parallel(true)
	var nova_posicao = Vector3(9.9, 2.8, position.z)
	
	tween.tween_property(self, "position", nova_posicao, 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation_degrees", Vector3(-90, 90, 0), 1.2).set_trans(Tween.TRANS_SINE)
		
	await tween.finished
	movendo = false

func descer() -> void:
	if movendo:
		return
		
	movendo = true 
	var tween = create_tween().set_parallel(true)
	var nova_posicao = Vector3(11.07, 2.909, position.z)
	
	tween.tween_property(self, "position", nova_posicao, 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation_degrees", Vector3(-50, 90, 0), 1.2).set_trans(Tween.TRANS_SINE)

	await tween.finished
	movendo = false

#	  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⠀    ⠀⠀⠀⡄⠀⠀
#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣿⠛⣿⠀⠀⠀⠀⣤⣿⢻⡇⠀
#⠀⠀⠀⠀⠀ ⠀⠀⠀⠀⠀⣤⣿⡛⠀⣤⣿⣿⣤⣤⣿⣿⣤⢸⡇⠀
#⠀⠀⠀⠀⠀⠀⠀⠀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀  
#⠀⠀⠀⠀⠀⠀⠀⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡗⠀
#⢠⣼⣿⣿⣿⣿⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷
#⢸⣿⣿⡟⠛⠛⢿⣿⣿⣿⣿⣿⣿⣿⣤⣤⣤⣿⣿⣿⣿⣤⣤⣼⣿
#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠋⠀   
#
#           █▀█ ▄▀█ █▀█ █ █▀█ █▀█    
#           █▀▀ █▀█ █▀▀ █ █▀▄ █▄█    
