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
	},
	# NUEVO: Datos de la última partida
	"ultima_partida": {
		"puntos": 0,
		"monedas_ganadas": 0,
		"monedas_totales": 0,
		"nuevo_record": false,
		"tiempo_sobrevivido": 0.0
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
				
				# Verificar que la estructura sea correcta
				if not "ultima_partida" in datos_juego:
					datos_juego["ultima_partida"] = {
						"puntos": 0,
						"monedas_ganadas": 0,
						"monedas_totales": 0,
						"nuevo_record": false,
						"tiempo_sobrevivido": 0.0
					}
					guardar_datos()
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

# ============================================
# FUNCIONES PARA ÚLTIMA PARTIDA (NUEVAS)
# ============================================

# Guardar datos de la última partida jugada
static func guardar_ultima_partida(puntos: int, monedas_ganadas: int, tiempo_sobrevivido: float = 0.0):
	# Calcular si es nuevo récord
	var nuevo_record = puntos > datos_juego["max_puntos"]
	
	# Guardar datos de la última partida
	datos_juego["ultima_partida"] = {
		"puntos": puntos,
		"monedas_ganadas": monedas_ganadas,
		"monedas_totales": datos_juego["monedas_totales"],
		"nuevo_record": nuevo_record,
		"tiempo_sobrevivido": tiempo_sobrevivido
	}
	
	# Actualizar estadísticas
	añadir_monedas(monedas_ganadas)
	actualizar_max_puntos(puntos)
	
	print("🎮 Última partida guardada:")
	print("  Puntos:", puntos)
	print("  Monedas ganadas:", monedas_ganadas)
	print("  Monedas totales:", datos_juego["monedas_totales"])
	print("  Nuevo récord:", nuevo_record)
	print("  Tiempo sobrevivido:", tiempo_sobrevivido)
	
	guardar_datos()

# Obtener datos de la última partida
static func obtener_ultima_partida() -> Dictionary:
	if not "ultima_partida" in datos_juego:
		return {
			"puntos": 0,
			"monedas_ganadas": 0,
			"monedas_totales": 0,
			"nuevo_record": false,
			"tiempo_sobrevivido": 0.0
		}
	return datos_juego["ultima_partida"].duplicate()

# Obtener puntos de la última partida
static func obtener_puntos_ultima_partida() -> int:
	return datos_juego["ultima_partida"]["puntos"] if "ultima_partida" in datos_juego else 0

# Obtener monedas ganadas en la última partida
static func obtener_monedas_ultima_partida() -> int:
	return datos_juego["ultima_partida"]["monedas_ganadas"] if "ultima_partida" in datos_juego else 0

# Verificar si la última partida fue récord
static func fue_record_ultima_partida() -> bool:
	return datos_juego["ultima_partida"]["nuevo_record"] if "ultima_partida" in datos_juego else false

# ============================================
# FUNCIONES ORIGINALES (MANTENIDAS)
# ============================================

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

# ============================================
# FUNCIONES DE DEPURACIÓN (NUEVAS)
# ============================================

# Mostrar todos los datos guardados
static func imprimir_datos():
	print("=== DATOS GUARDADOS ===")
	print("💰 Monedas totales:", datos_juego["monedas_totales"])
	print("🏆 Máximo puntos:", datos_juego["max_puntos"])
	print("🔥 Máximo combo:", datos_juego["max_combo"])
	print("⚡ Mejoras:", datos_juego["mejoras"])
	print("🎮 Última partida:", datos_juego["ultima_partida"])
	print("======================")

# Resetear datos (solo para pruebas)
static func resetear_datos():
	print("⚠️ RESETEANDO DATOS...")
	datos_juego = {
		"monedas_totales": 0,
		"max_puntos": 0,
		"max_combo": 0,
		"mejoras": {
			"vidas_iniciales": 0,
			"velocidad": 0,
			"duracion_poderes": 0,
			"imanes": 0
		},
		"ultima_partida": {
			"puntos": 0,
			"monedas_ganadas": 0,
			"monedas_totales": 0,
			"nuevo_record": false,
			"tiempo_sobrevivido": 0.0
		}
	}
	guardar_datos()
	print("✅ Datos reseteados")
