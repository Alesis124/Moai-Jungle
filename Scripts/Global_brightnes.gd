extends Node

var brillo: float = 1
var pantalla_completa: bool = false

func set_brillo(value: float):
	brillo = value
	if DisplayServer.window_get_mode() != 0:
		get_window().modulate.a = value  # Aplicar brillo si no está en pantalla completa
