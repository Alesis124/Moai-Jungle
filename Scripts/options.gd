extends Control

func _ready() -> void:
	pass

func _on_sonido_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Sonido.tscn")


func _on_graficos_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/graficos.tscn")


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
