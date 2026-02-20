extends CanvasLayer

@onready var sprite = $Sprite2D
@export var stamp_offset: Vector2 = Vector2(20, 50)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	sprite.modulate.a = 0
	sprite.scale = Vector2.ZERO

func _process(_delta):
	sprite.global_position = sprite.get_global_mouse_position() + stamp_offset

func aparecer():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.8)
	tween.tween_property(sprite, "scale", Vector2(0.8, 0.8), 1.0).set_trans(Tween.TRANS_ELASTIC)

func _input(event):
	if sprite.modulate.a > 0.9 and event is InputEventMouseButton:
		if event.pressed:
			sprite.scale = Vector2(0.7, 0.7)
		else:
			sprite.scale = Vector2(0.8, 0.8)
