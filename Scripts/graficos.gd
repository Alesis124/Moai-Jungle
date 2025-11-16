extends Control

@onready var porcentaje = $ColorRect/Porcentaje
@onready var opcion = $ColorRect/OpcionGraficos




func _ready() -> void:
	opcion.selected = 1 if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else 0






func _on_opcion_graficos_item_selected(index: int) -> void:
	if index == 0:  # Ventana
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:  # Pantalla completa
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)




func _on_btn_aceptar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/options.tscn")
