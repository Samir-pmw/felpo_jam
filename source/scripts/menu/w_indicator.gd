extends Sprite3D

func _ready():
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector3(1.1, 1.1, 1.1), 1.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(self, "modulate:a", 0.5, 1.2)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 1.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 1.2)
