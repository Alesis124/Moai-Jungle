extends Node



func _ready() -> void:
	pass




func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_juego_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/juego_2.tscn")


func _on_btn_upgrade_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/upgrade.tscn")
