extends Control
@onready var brillo = $ColorRect

func _ready() -> void:
	brillo.modulate.a = GlobalBrightnes.brillo

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/seleccion_videojuego.tscn")


func _on_option_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/options.tscn")





func _on_quit_pressed() -> void:
	get_tree().quit()
	
