extends Node
class_name SistemaGuardado

# Variables estáticas para acceso global
static var datos_juego = {
	"monedas_totales": 0,
	"max_puntos": 0,
	"max_combo": 0,
	"mejoras": {
		"vidas_iniciales": 0,
		"velocidad": 0,
		"duracion_poderes": 0,
		"imanes": 0
	}
}

# Inicializar automáticamente
static func _static_init():
	print("🔧 SistemaGuardado estático inicializado")
	cargar_datos()

# Guardar datos en archivo
static func guardar_datos():
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("res://data"):
		dir.make_dir("res://data")
	
	var file = FileAccess.open("res://data/saves.sav", FileAccess.WRITE)
	if file:
		file.store_var(datos_juego)
		file.close()
		print("💾 Guardado exitoso")
	else:
		print("❌ Error guardando: ", FileAccess.get_open_error())

# Cargar datos desde archivo
static func cargar_datos():
	# Crear directorio si no existe
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("res://data"):
		dir.make_dir("res://data")
		guardar_datos()  # Crear archivo inicial
		return
	
	if FileAccess.file_exists("res://data/saves.sav"):
		var file = FileAccess.open("res://data/saves.sav", FileAccess.READ)
		if file:
			# Verificar que el archivo no esté vacío
			if file.get_length() > 0:
				datos_juego = file.get_var()
				file.close()
				print("📂 Datos cargados")
			else:
				print("⚠️ Archivo vacío, creando nuevo")
				file.close()
				guardar_datos()
		else:
			print("❌ Error abriendo archivo")
			guardar_datos()
	else:
		print("📝 Creando archivo nuevo")
		guardar_datos()

# Añadir monedas
static func añadir_monedas(cantidad: int):
	datos_juego["monedas_totales"] += cantidad
	guardar_datos()

# Actualizar máximo puntaje
static func actualizar_max_puntos(puntos: int):
	if puntos > datos_juego["max_puntos"]:
		datos_juego["max_puntos"] = puntos
		guardar_datos()

# Actualizar máximo combo
static func actualizar_max_combo(combo: int):
	if combo > datos_juego["max_combo"]:
		datos_juego["max_combo"] = combo
		guardar_datos()

# Comprar mejora
static func comprar_mejora(tipo: String, costo: int) -> bool:
	if datos_juego["monedas_totales"] >= costo:
		datos_juego["monedas_totales"] -= costo
		datos_juego["mejoras"][tipo] += 1
		guardar_datos()
		return true
	return false

# Obtener valor de mejora
static func obtener_mejora(tipo: String) -> int:
	if tipo in datos_juego["mejoras"]:
		return datos_juego["mejoras"][tipo]
	return 0

# Obtener monedas totales
static func obtener_monedas() -> int:
	return datos_juego["monedas_totales"]

# Obtener máximo puntos
static func obtener_max_puntos() -> int:
	return datos_juego["max_puntos"]

# Obtener máximo combo
static func obtener_max_combo() -> int:
	return datos_juego["max_combo"]

# Obtener todas las mejoras
static func obtener_todas_mejoras() -> Dictionary:
	return datos_juego["mejoras"].duplicate()
