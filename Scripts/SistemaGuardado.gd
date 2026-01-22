extends Node
class_name SistemaGuardado

# Variables estáticas para acceso global
static var datos_juego = {
	"monedas_totales": 0,
	"max_puntos": 0,
	"max_combo": 0,
	
	# NUEVO: Mejoras de poder específicas
	"mejoras_poderes": {
		"escudo": {
			"nivel_desbloqueado": 1,
			"nivel_actual": 1,
			"duracion_base": 5.0,
			"duracion_por_nivel": 1.0
		},
		"alas": {
			"nivel_desbloqueado": 1,
			"nivel_actual": 1,
			"duracion_base": 5.0,
			"duracion_por_nivel": 1.0
		},
		"zapatillas": {
			"nivel_desbloqueado": 1,
			"nivel_actual": 1,
			"duracion_base": 5.0,
			"duracion_por_nivel": 1.0
		}
	},
	
	# Precios de mejora por nivel (puedes ajustarlos)
	"precios_mejoras": {
		"nivel_1": 1,
		"nivel_2": 5,
		"nivel_3": 10,
		"nivel_4": 20,
		"nivel_5": 30,
		"nivel_6": 40,
		"nivel_7": 50
	},
	
	# Datos de la última partida (inicializados por defecto)
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
	
	# Si el archivo no existe, crearlo con datos por defecto
	if not FileAccess.file_exists("res://data/saves.sav"):
		print("📝 Creando archivo nuevo con datos por defecto")
		guardar_datos()
		return
	
	# El archivo existe, intentar cargarlo
	var file = FileAccess.open("res://data/saves.sav", FileAccess.READ)
	if file:
		# Verificar que el archivo no esté vacío
		if file.get_length() > 0:
			var datos_cargados = file.get_var()
			file.close()
			
			# Verificar que sea un diccionario válido
			if datos_cargados is Dictionary:
				# Migración: asegurar que todas las estructuras necesarias existan
				if not "mejoras_poderes" in datos_cargados:
					datos_cargados["mejoras_poderes"] = datos_juego["mejoras_poderes"].duplicate()
				
				if not "precios_mejoras" in datos_cargados:
					datos_cargados["precios_mejoras"] = datos_juego["precios_mejoras"].duplicate()
				
				if not "ultima_partida" in datos_cargados:
					datos_cargados["ultima_partida"] = datos_juego["ultima_partida"].duplicate()
				
				# Verificar estructura de ultima_partida
				var ultima_partida = datos_cargados["ultima_partida"]
				if not "puntos" in ultima_partida:
					ultima_partida["puntos"] = 0
				if not "monedas_ganadas" in ultima_partida:
					ultima_partida["monedas_ganadas"] = 0
				if not "monedas_totales" in ultima_partida:
					ultima_partida["monedas_totales"] = datos_cargados.get("monedas_totales", 0)
				if not "nuevo_record" in ultima_partida:
					ultima_partida["nuevo_record"] = false
				if not "tiempo_sobrevivido" in ultima_partida:
					ultima_partida["tiempo_sobrevivido"] = 0.0
				
				datos_juego = datos_cargados
				print("📂 Datos cargados correctamente")
			else:
				print("⚠️ Archivo corrupto, creando nuevo")
				file.close()
				guardar_datos()
		else:
			print("⚠️ Archivo vacío, creando nuevo")
			file.close()
			guardar_datos()
	else:
		print("❌ Error abriendo archivo, creando nuevo")
		guardar_datos()

# ============================================
# FUNCIONES PARA MEJORAS DE PODERES
# ============================================

# Obtener nivel actual de un poder
static func obtener_nivel_actual(poder: String) -> int:
	if poder in datos_juego["mejoras_poderes"]:
		return datos_juego["mejoras_poderes"][poder]["nivel_actual"]
	return 1

# Obtener nivel desbloqueado de un poder
static func obtener_nivel_desbloqueado(poder: String) -> int:
	if poder in datos_juego["mejoras_poderes"]:
		return datos_juego["mejoras_poderes"][poder]["nivel_desbloqueado"]
	return 1

# Cambiar nivel actual de un poder
static func cambiar_nivel_actual(poder: String, nuevo_nivel: int) -> bool:
	if poder in datos_juego["mejoras_poderes"]:
		var max_nivel = datos_juego["mejoras_poderes"][poder]["nivel_desbloqueado"]
		if nuevo_nivel >= 1 and nuevo_nivel <= max_nivel:
			datos_juego["mejoras_poderes"][poder]["nivel_actual"] = nuevo_nivel
			guardar_datos()
			return true
	return false

# Mejorar (desbloquear siguiente nivel) de un poder
static func mejorar_poder(poder: String, costo: int) -> bool:
	if poder in datos_juego["mejoras_poderes"]:
		var nivel_actual = datos_juego["mejoras_poderes"][poder]["nivel_desbloqueado"]
		
		# Verificar si se pueden mejorar más niveles (máximo 7)
		if nivel_actual >= 7:
			return false
		
		# Verificar si hay suficientes monedas
		if datos_juego["monedas_totales"] >= costo:
			datos_juego["monedas_totales"] -= costo
			datos_juego["mejoras_poderes"][poder]["nivel_desbloqueado"] += 1
			
			# Si el nivel actual era el máximo desbloqueado, subirlo también
			if datos_juego["mejoras_poderes"][poder]["nivel_actual"] == nivel_actual:
				datos_juego["mejoras_poderes"][poder]["nivel_actual"] += 1
			
			guardar_datos()
			return true
	return false

# Obtener duración de un poder
static func obtener_duracion_poder(poder: String) -> float:
	if poder in datos_juego["mejoras_poderes"]:
		var datos = datos_juego["mejoras_poderes"][poder]
		return datos["duracion_base"] + ((datos["nivel_actual"] - 1) * datos["duracion_por_nivel"])
	return 5.0

# Obtener precio para el siguiente nivel
static func obtener_precio_siguiente_nivel(poder: String) -> int:
	if poder in datos_juego["mejoras_poderes"]:
		var nivel_actual = datos_juego["mejoras_poderes"][poder]["nivel_desbloqueado"]
		
		if nivel_actual >= 7:
			return 0  # Ya está al máximo nivel
		
		var clave_nivel = "nivel_" + str(nivel_actual + 1)
		if clave_nivel in datos_juego["precios_mejoras"]:
			return datos_juego["precios_mejoras"][clave_nivel]
	
	return 0

# ============================================
# FUNCIONES ORIGINALES MANTENIDAS Y AÑADIDAS
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
	
	print("🎮 Última partida guardada")
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
	
	# Asegurar que todos los campos existan
	var ultima_partida = datos_juego["ultima_partida"]
	
	if not ultima_partida is Dictionary:
		return {
			"puntos": 0,
			"monedas_ganadas": 0,
			"monedas_totales": datos_juego.get("monedas_totales", 0),
			"nuevo_record": false,
			"tiempo_sobrevivido": 0.0
		}
	
	# Completar campos faltantes
	if not "puntos" in ultima_partida:
		ultima_partida["puntos"] = 0
	if not "monedas_ganadas" in ultima_partida:
		ultima_partida["monedas_ganadas"] = 0
	if not "monedas_totales" in ultima_partida:
		ultima_partida["monedas_totales"] = datos_juego.get("monedas_totales", 0)
	if not "nuevo_record" in ultima_partida:
		ultima_partida["nuevo_record"] = false
	if not "tiempo_sobrevivido" in ultima_partida:
		ultima_partida["tiempo_sobrevivido"] = 0.0
	
	return ultima_partida.duplicate()

# Obtener puntos de la última partida
static func obtener_puntos_ultima_partida() -> int:
	var ultima_partida = obtener_ultima_partida()
	return ultima_partida.get("puntos", 0)

# Obtener monedas ganadas en la última partida
static func obtener_monedas_ultima_partida() -> int:
	var ultima_partida = obtener_ultima_partida()
	return ultima_partida.get("monedas_ganadas", 0)

# Verificar si la última partida fue récord
static func fue_record_ultima_partida() -> bool:
	var ultima_partida = obtener_ultima_partida()
	return ultima_partida.get("nuevo_record", false)

# Obtener monedas totales
static func obtener_monedas() -> int:
	return datos_juego.get("monedas_totales", 0)

# Obtener máximo puntos
static func obtener_max_puntos() -> int:
	return datos_juego.get("max_puntos", 0)

# Obtener máximo combo
static func obtener_max_combo() -> int:
	return datos_juego.get("max_combo", 0)

# ============================================
# FUNCIÓN PARA OBTENER TODAS LAS MEJORAS (COMPATIBILIDAD)
# ============================================

# Obtener todas las mejoras (para compatibilidad con código existente)
static func obtener_todas_mejoras() -> Dictionary:
	# Crear un diccionario con la estructura esperada por el código antiguo
	var mejoras_compatibles = {
		"vidas_iniciales": 0,
		"velocidad": 0,
		"duracion_poderes": 0,
		"imanes": 0
	}
	
	# Comprobar si existen las viejas mejoras
	if "mejoras" in datos_juego and typeof(datos_juego["mejoras"]) == TYPE_DICTIONARY:
		var viejas_mejoras = datos_juego["mejoras"]
		
		# Transferir valores si existen
		if "vidas_iniciales" in viejas_mejoras:
			mejoras_compatibles["vidas_iniciales"] = viejas_mejoras["vidas_iniciales"]
		if "velocidad" in viejas_mejoras:
			mejoras_compatibles["velocidad"] = viejas_mejoras["velocidad"]
		if "duracion_poderes" in viejas_mejoras:
			mejoras_compatibles["duracion_poderes"] = viejas_mejoras["duracion_poderes"]
		if "imanes" in viejas_mejoras:
			mejoras_compatibles["imanes"] = viejas_mejoras["imanes"]
	
	print("📋 Mejoras cargadas (compatibilidad): ", mejoras_compatibles)
	return mejoras_compatibles

# ============================================
# FUNCIONES DE DEPURACIÓN
# ============================================

# Mostrar todos los datos guardados
static func imprimir_datos():
	print("=== DATOS GUARDADOS ===")
	print("💰 Monedas totales:", datos_juego.get("monedas_totales", 0))
	print("🏆 Máximo puntos:", datos_juego.get("max_puntos", 0))
	print("🔥 Máximo combo:", datos_juego.get("max_combo", 0))
	print("⚡ Mejoras de poderes:", datos_juego.get("mejoras_poderes", {}))
	
	# También mostrar las viejas mejoras si existen
	if "mejoras" in datos_juego:
		print("🔧 Mejoras antiguas:", datos_juego["mejoras"])
	
	print("💲 Precios:", datos_juego.get("precios_mejoras", {}))
	print("🎮 Última partida:", datos_juego.get("ultima_partida", {}))
	print("======================")

# Resetear datos (solo para pruebas)
static func resetear_datos():
	print("⚠️ RESETEANDO DATOS...")
	datos_juego = {
		"monedas_totales": 0,
		"max_puntos": 0,
		"max_combo": 0,
		"mejoras_poderes": {
			"escudo": {
				"nivel_desbloqueado": 1,
				"nivel_actual": 1,
				"duracion_base": 5.0,
				"duracion_por_nivel": 1.0
			},
			"alas": {
				"nivel_desbloqueado": 1,
				"nivel_actual": 1,
				"duracion_base": 5.0,
				"duracion_por_nivel": 1.0
			},
			"zapatillas": {
				"nivel_desbloqueado": 1,
				"nivel_actual": 1,
				"duracion_base": 5.0,
				"duracion_por_nivel": 1.0
			}
		},
		"precios_mejoras": {
			"nivel_1": 1,
			"nivel_2": 5,
			"nivel_3": 10,
			"nivel_4": 20,
			"nivel_5": 30,
			"nivel_6": 40,
			"nivel_7": 50
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
