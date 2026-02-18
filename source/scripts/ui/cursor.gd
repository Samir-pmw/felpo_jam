extends CanvasLayer

@onready var sprite = $Sprite2D
@export var stamp_offset: Vector2 = Vector2(20, 50) 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	sprite.global_position = sprite.get_global_mouse_position() + stamp_offset

# Temporário (Até termos animação)
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			sprite.scale = Vector2(0.9, 0.9)
		else:
			# Pop back to normal size
			sprite.scale = Vector2(1.0, 1.0)
