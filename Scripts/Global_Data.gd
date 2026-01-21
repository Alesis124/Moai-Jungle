extends Node

var monedas_totales = 0
var mejoras_compradas = {}

func guardar_datos():
	var config = ConfigFile.new()
	config.set_value("jugador", "monedas", monedas_totales)
	config.set_value("jugador", "mejoras", mejoras_compradas)
	config.save("user://datos_juego.cfg")

func cargar_datos():
	var config = ConfigFile.new()
	var err = config.load("user://datos_juego.cfg")
	if err == OK:
		monedas_totales = config.get_value("jugador", "monedas", 0)
		mejoras_compradas = config.get_value("jugador", "mejoras", {})
