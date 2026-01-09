extends Control

func _ready() -> void:
	get_window().title = "Moai Jungle"



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/seleccion_videojuego.tscn")


func _on_option_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/options.tscn")





func _on_quit_pressed() -> void:
	get_tree().quit()
	
