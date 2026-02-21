extends Button

func setup(ability: AbilityData):
	$HBoxContainer/NameLabel.text = ability.name
	$HBoxContainer/DmgLabel.text = "Dano: " + str(ability.damage)
	$HBoxContainer/RangeLabel.text = "Alcance: " + str(ability.ability_range)
	
	var tipo_texto = AbilityData.DamageType.keys()[ability.damage_type]
	$HBoxContainer/TypeLabel.text = "Tipo: " + tipo_texto
	
	$HBoxContainer/CostLabel.text = "Custo: " + str(ability.cost) + " MP"
	
	
