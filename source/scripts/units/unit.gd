extends Node2D
class_name Unit

@export var stats: UnitData 

var current_hp: int

func _ready():
	if stats:
		current_hp = stats.max_hp
		
		if has_node("Sprite2D"):
			$Sprite2D.texture = stats.texture
			
		print(stats.job_name, " initialized with ", current_hp, " HP.")
