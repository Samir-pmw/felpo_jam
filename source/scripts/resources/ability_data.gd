extends Resource
class_name AbilityData

enum DamageType { PIERCING, SLASH, BLUNT, FIRE, ELECTRIC, ICE }

@export var name: String = "Slash"
@export var damage: int = 5
@export var ability_range: int = 1 
@export var damage_type: DamageType = DamageType.SLASH
@export var cost: int = 5
