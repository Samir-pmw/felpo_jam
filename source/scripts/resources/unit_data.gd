extends Resource
class_name UnitData

@export_group("Identity")
@export var job_name: String = "New Class"
@export var texture: Texture2D 
@export var is_enemy: bool = false 

@export_group("Stats")
@export var max_hp: int = 10
@export var move_range: int = 3

@export_group("Combat")
@export var abilities: Array[AbilityData]
