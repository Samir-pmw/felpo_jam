extends Control

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/tutorial.tscn")

func _on_load_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/tutorial.tscn")

func _on_config_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/config.tscn")
	
func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/credits.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
