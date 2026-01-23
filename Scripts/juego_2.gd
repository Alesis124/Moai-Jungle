extends Node

var vidas = 3
@onready var coco = $coco
@onready var barril = $barril
@onready var corazon = $Corazon
@onready var escudo = $Escudo
@onready var duracion = $Duracion
@onready var ala = $Ala
@onready var zapatilla = $Zapa

# NUEVO: Referencia al sistema de guardado
@onready var sistema_guardado = preload("res://Scripts/SistemaGuardado.gd")
var datos_guardados = null

var vidas_por_puntos_dadas = 0
var timer_escudo
var puntos_tiempo := 0.0
var timer_ala
var timer_zapa
var invulnerable := false
var invulnerabilidad_timer
var doble_salto := false
var velocidad_extra := false
var nCorazon
var nEscudo
var nAla
var nZapa
var VELOCIDAD_BARRIL = 200
var velocidad_caida = 200.0
@onready var pared_derecha = $suelo/pared_dr
@onready var pared_izquierda = $suelo/pared_izq
@onready var jugador = $Jugador
var veces = 2
var max_cocos = 4  # Máximo de cocos en pantalla
var cocos_en_pantalla = 0  # Contador de cocos
var tiempo_entre_cocos = 0.4  # Segundos entre cada coco
var tiempo_actual = 0.0
var cocoCreado = Area2D
var vida = 3
@onready var textoVidas = $vidas
@onready var tiempotxt = $Tiempo
var puntos = 0
var carga = 0
var pantalla_ancho
var max_barril = 7
var espera = 3.2
var screen_size := Vector2.ZERO
var ancho_entre_paredes

# NUEVAS VARIABLES AÑADIDAS
var combo = 0
var max_combo = 0
var tiempo_ultimo_punto = 0.0
var combo_timeout = 1.5
var combo_multiplier = 1
var monedas = 0
var monedas_totales = 0
var mejoras = {
	"vidas_iniciales": 0,
	"velocidad": 0,
	"duracion_poderes": 0,
	"imanes": 0
}
var iman_activado = false
var timer_iman
var particula_timer
@onready var combo_label = $ComboLabel
@onready var moneda_escena = preload("res://sprites/coin.tscn")
@onready var monedas_label = $MonedasLabel

# NUEVAS VARIABLES PARA SISTEMA DE TIEMPO
var tiempo_restante = 150.0  # 2 minutos y medio
var tiempo_inicial = 150.0
var tiempo_supervivencia = 0.0
var ultimo_punto_supervivencia = 0.0
var tiempo_por_nivel = 30.0  # Cada 30 segundos aumenta dificultad
var tiempo_ultimo_nivel = 0.0
var nivel_dificultad = 1
var juego_terminado = false
@onready var puntos_label = $PuntosLabel

# VARIABLES PARA APARICIÓN POR TIEMPO
var ultima_moneda_tiempo = 0.0
var intervalo_monedas = 30.0  # Moneda cada 30 segundos
var ultimo_powerup_tiempo = 0.0
var intervalo_powerups = 20.0  # Power-up cada 20 segundos

# NUEVAS VARIABLES PARA SISTEMA DE COMBO CON DESVANECIMIENTO
var combo_timeout_total = 3.0  # 3 segundos para perder combo
var tiempo_desde_ultimo_combo = 0.0
var combo_fade_timer = 0.0
var combo_fade_duration = 1.0  # 1 segundo para desvanecerse completamente

# NUEVO: Variables para el sistema de barriles mejorado
var barriles_minimos = 3  # Número mínimo de barriles en pantalla
var barriles_en_camino = []  # Array para controlar barriles activos
var timer_generacion_barriles = null
var tiempo_entre_barriles = 1.5  # Tiempo inicial entre generación de barriles
var barriles_generados = 0  # Contador total de barriles generados
var barriles_por_nivel = [6, 7, 8, 9, 10, 11]  # Barriles máximos por nivel de dificultad
var velocidad_por_nivel = [100, 120, 150, 180, 210, 240]  # Velocidad por nivel
var nivel_actual_barriles = 0  # Nivel de dificultad actual para barriles
var zonas_seguras = []  # Zonas donde no se pueden generar barriles
var distancia_minima_entre_barriles = 60  # Distancia mínima entre barriles

# NUEVO: Variables para la animación de romperse
var barriles_rotos = []  # Barriles que se están rompiendo

# ============================================
# NUEVAS FUNCIONES PARA EL SISTEMA DE MEJORAS
# ============================================

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# NUEVO: Cargar datos guardados
	cargar_datos_guardados()
	
	pantalla_ancho = get_viewport().size.x
	GlobalAudio.stream = preload("res://sounds/very-lush-and-swag-loop-74140.mp3")
	GlobalAudio.stream.loop = true
	GlobalAudio.play()
	textoVidas.text = "Vidas: " + str(vida)
	duracion.visible = false
	
	# NUEVO: Inicializar sistema de barriles en lugar de crear_barril()
	inicializar_sistema_barriles()

	# NUEVO: Aplicar mejoras compradas
	aplicar_mejoras_guardadas()

	# Timers separados para cada poder - CON DURACIONES DINÁMICAS
	timer_escudo = Timer.new()
	timer_ala = Timer.new()
	timer_zapa = Timer.new()
	
	# NUEVOS TIMERS AÑADIDOS
	timer_iman = Timer.new()
	particula_timer = Timer.new()

	timer_escudo.one_shot = true
	timer_ala.one_shot = true
	timer_zapa.one_shot = true
	
	# NUEVOS TIMERS CONFIGURADOS
	timer_iman.one_shot = true
	particula_timer.wait_time = 0.05
	particula_timer.autostart = true
	particula_timer.timeout.connect(_on_particula_timer_timeout)

	# Configurar tiempos iniciales basados en el sistema de guardado
	actualizar_duraciones_poderes()

	timer_escudo.timeout.connect(_fin_escudo)
	timer_ala.timeout.connect(_fin_ala)
	timer_zapa.timeout.connect(_fin_zapatilla)
	timer_iman.timeout.connect(_fin_iman)

	add_child(timer_escudo)
	add_child(timer_ala)
	add_child(timer_zapa)
	add_child(timer_iman)
	add_child(particula_timer)

	$Jugador/muerto.area_entered.connect(detecta)
	ancho_entre_paredes = pared_derecha.position.x - pared_izquierda.position.x
	
	# Inicializar combo label
	if combo_label:
		combo_label.visible = false
		combo_label.add_theme_font_size_override("font_size", 32)
		combo_label.add_theme_color_override("font_color", Color(1, 1, 0))
	
	# Inicializar monedas label
	if monedas_label:
		monedas_label.text = "Monedas: 0"
	
	# Inicializar tiempo label
	if tiempotxt:
		actualizar_tiempo_display()
	
	# Inicializar puntos label
	if puntos_label:
		puntos_label.text = "Puntos: 0"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if juego_terminado:
		return
	
	puntos_tiempo += delta
	tiempo_supervivencia += delta
	tiempo_restante -= delta
	tiempo_desde_ultimo_combo += delta
	
	var vidas_esperadas = puntos / 1000

	if vidas_esperadas > vidas_por_puntos_dadas:
		vida += 1
		vidas_por_puntos_dadas = vidas_esperadas
		textoVidas.text = "Vidas: " + str(vida)

		mostrar_texto_flotante_en_posicion(
			"+1 VIDA",
			Color(1, 0, 0),
			jugador.position - Vector2(0, 50),
			26
		)

	# NUEVO: Sistema de desvanecimiento del combo label
	if combo > 0 and combo_label and combo_label.visible:
		combo_fade_timer += delta
		
		# Calcular tiempo restante para perder combo
		var tiempo_restante_combo = combo_timeout_total - tiempo_desde_ultimo_combo
		
		# Si quedan menos de 1 segundo, empezar a desvanecer
		if tiempo_restante_combo < combo_fade_duration:
			var alpha = tiempo_restante_combo / combo_fade_duration
			combo_label.modulate.a = alpha
			
			# También reducir tamaño
			var scale_factor = 0.8 + (alpha * 0.2)
			combo_label.scale = Vector2(scale_factor, scale_factor)
		
		# Si se acabó el tiempo del combo, resetearlo
		if tiempo_desde_ultimo_combo >= combo_timeout_total:
			reset_combo()
	
	# NUEVO: Crear objetos basados en tiempo
	crear_objetos_por_tiempo(delta)
	
	# Actualizar display de tiempo
	if tiempotxt:
		actualizar_tiempo_display()
	
	# Verificar si se acabó el tiempo
	if tiempo_restante <= 0:
		terminar_juego_por_tiempo()
		return
	
	# Aumentar dificultad basado en tiempo transcurrido
	var tiempo_transcurrido = tiempo_inicial - tiempo_restante
	if tiempo_transcurrido - tiempo_ultimo_nivel >= tiempo_por_nivel:
		aumentar_dificultad_por_tiempo()
		tiempo_ultimo_nivel = tiempo_transcurrido
	
	# Comprobar combo timeout
	var ahora = Time.get_ticks_msec() / 1000.0
	if ahora - tiempo_ultimo_punto > combo_timeout and combo > 0:
		reset_combo()
	
	if puntos_tiempo >= 1.0:
		# Dar puntos por supervivencia cada segundo
		puntos += 1
		puntos_tiempo = 0.0
		
		# Actualizar tiempo para combo
		tiempo_ultimo_punto = ahora
		
		# Actualizar display de puntos
		if puntos_label:
			puntos_label.text = "Puntos: " + str(puntos)
	
	# Cada 10 segundos, dar puntos extra por supervivencia
	if tiempo_supervivencia - ultimo_punto_supervivencia >= 10.0:
		var puntos_supervivencia = 25 + int(puntos / 100)
		puntos += puntos_supervivencia
		ultimo_punto_supervivencia = tiempo_supervivencia
		
		# Mostrar texto de supervivencia
		var rotacion = randf_range(-0.15, 0.15)
		mostrar_texto_flotante_en_posicion(
			"SUPERVIVENCIA +%d" % puntos_supervivencia,
			Color(0, 1, 1),
			Vector2(get_viewport().size.x / 2, 100),
			26,
			rotacion
		)
		
		# Actualizar puntos display
		if puntos_label:
			puntos_label.text = "Puntos: " + str(puntos)

	tiempo_actual += delta

	if duracion.visible and (invulnerable or doble_salto or velocidad_extra or iman_activado):
		duracion.value -= delta
	
	# Actualizar monedas label
	if monedas_label:
		monedas_label.text = "Monedas: " + str(monedas)

	if cocos_en_pantalla < max_cocos and tiempo_actual >= tiempo_entre_cocos:
		crear_coco()
		tiempo_actual = 0
		tiempo_entre_cocos = max(0.1, tiempo_entre_cocos - 0.005)
	
	# NUEVO: Actualizar posiciones de barriles y verificar colisiones
	actualizar_barriles(delta)
	
	# NUEVO: Actualizar zona segura periódicamente
	if tiempo_actual >= 0.5:  # Cada medio segundo
		actualizar_zona_segura()
		tiempo_actual = 0
	
	# NUEVO: Actualizar animaciones de barriles rotos
	actualizar_barriles_rotos(delta)
	
	# Efecto imán
	if iman_activado:
		atraer_items()

# ============================================
# NUEVO: SISTEMA DE BARRILES MEJORADO
# ============================================

func inicializar_sistema_barriles():
	# Crear timer para generación de barriles
	timer_generacion_barriles = Timer.new()
	timer_generacion_barriles.wait_time = tiempo_entre_barriles
	timer_generacion_barriles.one_shot = false
	timer_generacion_barriles.timeout.connect(generar_barril_controlado)
	add_child(timer_generacion_barriles)
	
	# Crear barriles iniciales
	for i in range(barriles_minimos):
		generar_barril_inicial(i * 0.8)  # Espaciados para no colisionar
	
	# Iniciar timer después de un breve delay
	await get_tree().create_timer(2.0).timeout
	timer_generacion_barriles.start()
	
	# Configurar zona segura inicial (alrededor del jugador)
	actualizar_zona_segura()

func generar_barril_inicial(delay: float = 0.0):
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	# Crear barril inicial con spawn seguro
	crear_barril_con_control()

func generar_barril_controlado():
	# Verificar si podemos generar más barriles según el nivel actual
	if barriles_en_camino.size() < barriles_por_nivel[nivel_actual_barriles]:
		if crear_barril_con_control():
			barriles_generados += 1
			
			# Aumentar dificultad cada cierta cantidad de barriles generados
			if barriles_generados % 25 == 0 and nivel_actual_barriles < barriles_por_nivel.size() - 1:
				aumentar_dificultad_barriles()

# En la función crear_barril_con_control():
# Modifica la función crear_barril_con_control():
func crear_barril_con_control() -> bool:
	var escena_barril = preload("res://sprites/barril.tscn")
	var barril_nuevo = escena_barril.instantiate()
	add_child(barril_nuevo)
	
	# Determinar dirección aleatoria (izquierda o derecha)
	var direccion = 1 if randf() > 0.5 else -1
	barril_nuevo.set_meta("direccion", direccion)
	barril_nuevo.set_meta("esta_roto", false)
	
	# Asignar dirección y velocidad al barril
	barril_nuevo.direccion = direccion
	var velocidad_actual = velocidad_por_nivel[nivel_actual_barriles]
	barril_nuevo.velocidad = velocidad_actual
	barril_nuevo.set_meta("velocidad", velocidad_actual)
	
	# Posicionar barril fuera de la pantalla según la dirección
	var posicion_inicial = Vector2()
	var pantalla_ancho = get_viewport().get_visible_rect().size.x
	var altura_barril = 550
	
	if direccion == 1:  # Viene de la izquierda
		posicion_inicial = Vector2(-80, altura_barril)
	else:  # Viene de la derecha
		posicion_inicial = Vector2(pantalla_ancho + 80, altura_barril)
	
	barril_nuevo.position = posicion_inicial
	
	# Conectar señales del barril
	barril_nuevo.connect("choco_con_pared", Callable(self, "_on_barril_choco_con_pared").bind(barril_nuevo))
	barril_nuevo.connect("barril_roto", Callable(self, "_on_barril_roto").bind(barril_nuevo))
	
	# Verificar colisiones con otros barriles antes de añadir
	if verificar_colision_segura(barril_nuevo):
		barriles_en_camino.append(barril_nuevo)
		return true
	else:
		# Si hay colisión, reposicionar
		var nuevo_posicion = encontrar_posicion_segura(barril_nuevo, direccion)
		if nuevo_posicion != Vector2.ZERO:
			barril_nuevo.position = nuevo_posicion
			barriles_en_camino.append(barril_nuevo)
			return true
		else:
			barril_nuevo.queue_free()
			return false


func _on_barril_roto(barril):
	if barril.esta_roto:
		return

	# Daño al jugador
	if not invulnerable:
		aplicar_dano_por_barril()

	# Romper barril (ANIMACIÓN + BORRADO)
	barril.romper()

	# Puntos combo
	añadir_puntos_con_combo(15)

	# Texto
	mostrar_texto_flotante_en_posicion(
		"¡BARRIL ROTO!",
		Color(0.8, 0.4, 0),
		barril.position - Vector2(0, 40),
		24
	)

	# Sonido
	Efectos.stream = preload("res://sounds/daño.mp3")
	Efectos.play()

	# Quitar de la lista
	var i = barriles_en_camino.find(barril)
	if i != -1:
		barriles_en_camino.remove_at(i)



func encontrar_posicion_segura(barril: Node2D, direccion: int) -> Vector2:
	var pantalla_ancho = get_viewport().get_visible_rect().size.x
	var altura_barril = 550
	
	# Intentar diferentes posiciones MANTENIENDO LA MISMA ALTURA
	# Solo ajustamos el momento de spawn (más adelante o más atrás)
	for i in range(5):
		var offset_x = randf_range(-50, 50)  # Offset horizontal para evitar colisión
		var nueva_posicion: Vector2
		
		if direccion == 1:
			nueva_posicion = Vector2(-80 + offset_x, altura_barril)  # Misma altura
		else:
			nueva_posicion = Vector2(pantalla_ancho + 80 + offset_x, altura_barril)  # Misma altura
		
		barril.position = nueva_posicion
		if verificar_colision_segura(barril):
			return nueva_posicion
	
	# Si no encontramos posición, devolver la posición original con altura fija
	if direccion == 1:
		return Vector2(-80, altura_barril)
	else:
		return Vector2(pantalla_ancho + 80, altura_barril)



func verificar_colision_segura(barril_nuevo: Node2D) -> bool:
	for barril_existente in barriles_en_camino:
		if is_instance_valid(barril_existente) and barril_existente != barril_nuevo:
			# Calcular distancia entre barriles
			var distancia = barril_nuevo.position.distance_to(barril_existente.position)
			
			# Si están muy cerca, hay colisión potencial
			if distancia < distancia_minima_entre_barriles:
				return false
	
	# Verificar con zona segura del jugador
	if is_instance_valid(jugador):
		var distancia_al_jugador = barril_nuevo.position.distance_to(jugador.position)
		if distancia_al_jugador < 150:
			return false
	
	return true

func actualizar_zona_segura():
	# Actualizar zonas donde no se deben generar barriles
	zonas_seguras.clear()
	
	# Zona alrededor del jugador
	if is_instance_valid(jugador):
		zonas_seguras.append(jugador.position)

func aumentar_dificultad_barriles():
	if nivel_actual_barriles < barriles_por_nivel.size() - 1:
		nivel_actual_barriles += 1
		
		# Aumentar velocidad
		VELOCIDAD_BARRIL = velocidad_por_nivel[nivel_actual_barriles]
		
		# Reducir tiempo entre generación de barriles
		tiempo_entre_barriles = max(0.6, tiempo_entre_barriles * 0.8)
		if timer_generacion_barriles:
			timer_generacion_barriles.wait_time = tiempo_entre_barriles
		
		# Mostrar mensaje de aumento de dificultad
		mostrar_texto_flotante_en_posicion(
			"¡BARRILES MÁS RÁPIDOS!",
			Color(1, 0.5, 0),
			Vector2(get_viewport().size.x / 2, 250),
			28
		)
		
		print("Nivel de dificultad de barriles aumentado a: ", nivel_actual_barriles)

# Modifica la función actualizar_barriles para eliminar barriles rotos:
# En la función _process(delta), dentro del loop que actualiza barriles:
func actualizar_barriles(delta: float):
	# Mover todos los barriles activos
	for i in range(barriles_en_camino.size() - 1, -1, -1):
		var barril = barriles_en_camino[i]
		
		if is_instance_valid(barril):
			# Verificar si el barril está roto
			if barril.esta_roto:
				# Si está roto, remover de la lista
				barriles_en_camino.remove_at(i)
				continue
			
			# Mover el barril
			var direccion = barril.direccion
			var velocidad = barril.velocidad
			barril.position.x += direccion * velocidad * delta
			
			# PUNTOS POR ESQUIVAR BARRIL (esto es lo que te falta)
			if is_instance_valid(jugador):
				var distancia = jugador.position.distance_to(barril.position)
				if distancia < 100 and randf() < 0.1:  # 10% de probabilidad por frame
					puntos_por_esquivar_barril(barril.position)
			
			# Verificar si el barril salió de la pantalla
			var pantalla_ancho = get_viewport().get_visible_rect().size.x
			if (barril.direccion == 1 and barril.position.x > pantalla_ancho + 150) or \
			   (barril.direccion == -1 and barril.position.x < -150):
				eliminar_barril(barril)
		else:
			# Si el barril ya no es válido, removerlo de la lista
			barriles_en_camino.remove_at(i)


func puntos_por_esquivar_barril(barril_pos: Vector2):
	if not is_instance_valid(jugador):
		return
	
	var distancia = jugador.position.distance_to(barril_pos)
	
	if distancia < 100:  # Muy cerca del barril
		var puntos_extra = int(120 / (distancia + 1))  # Más puntos cuanto más cerca
		puntos += puntos_extra
		
		# Mostrar texto en posición del barril
		var rotacion = randf_range(-0.2, 0.2)
		mostrar_texto_flotante_en_posicion(
			"+%d" % puntos_extra,
			Color(0, 1, 0),
			barril_pos - Vector2(0, 30),
			24,
			rotacion
		)
		
		# Añadir al combo (pero no añadir puntos extra, solo actualizar combo)
		añadir_puntos_con_combo(0)  # Solo actualiza combo, no puntos
		
		# Actualizar display de puntos
		if puntos_label:
			puntos_label.text = "Puntos: " + str(puntos)

func puntos_por_salto_preciso():
	if not is_instance_valid(jugador):
		return
	
	# Verificar si el jugador está saltando cerca de un barril
	for barril in barriles_en_camino:
		if is_instance_valid(barril):
			var distancia = jugador.position.distance_to(barril.position)
			if distancia < 100 and jugador.velocity.y < 0:  # Saltando cerca de barril
				var puntos_extra = 15
				puntos += puntos_extra
				
				var rotacion = randf_range(-0.4, 0.4)
				mostrar_texto_flotante_en_posicion(
					"SALTO +%d" % puntos_extra,
					Color(0.5, 0, 1),
					jugador.position - Vector2(0, 50),
					20,
					rotacion
				)
				
				# Actualizar display de puntos
				if puntos_label:
					puntos_label.text = "Puntos: " + str(puntos)
				break


# En tu script del jugador (Jugador.gd):
func saltar():
	if Input.is_action_just_pressed("salto"):
		# Tu lógica de salto...
		
		# Llamar a la función de puntos por salto preciso
		if get_parent().has_method("puntos_por_salto_preciso"):
			get_parent().puntos_por_salto_preciso()





func _on_barril_colision(area: Area2D, barril: Node2D):
	# Verificar si el área que colisionó es el jugador
	if area.get_parent() == jugador and !invulnerable:
		# Verificar si el barril aún hace daño
		if barril.get_meta("hace_dano", true):
			# Romper el barril
			romper_barril(barril)
			
			# Aplicar daño al jugador
			aplicar_dano_por_barril()
	else:
		# Verificar colisión con otro barril
		for otro_barril in barriles_en_camino:
			if otro_barril != barril and is_instance_valid(otro_barril):
				var distancia = barril.position.distance_to(otro_barril.position)
				if distancia < 60:  # Distancia de colisión entre barriles
					# Si colisionan, cambiar dirección del más nuevo
					var direccion_actual = barril.get_meta("direccion", 1)
					barril.set_meta("direccion", -direccion_actual)
					
					# Dar un pequeño empujón
					barril.position.x += -direccion_actual * 20

func romper_barril(barril: Node2D):
	# Marcar barril como roto y que no hace daño
	barril.set_meta("esta_roto", true)
	barril.set_meta("hace_dano", false)
	
	# Crear efecto visual de rotura
	crear_efecto_rotura(barril.position)
	
	# Ocultar el barril original
	if barril.has_node("Sprite2D"):
		barril.get_node("Sprite2D").visible = false
	
	# Desactivar colisiones
	var area_colision = barril.get_node_or_null("Area2D")
	if area_colision:
		area_colision.monitoring = false
		area_colision.monitorable = false
	
	# Agregar a la lista de barriles rotos para animación
	barriles_rotos.append({
		"barril": barril,
		"tiempo": 0.0,
		"duracion": 0.8,  # Duración de la animación de rotura
		"posicion": barril.position
	})
	
	# Puntos por romper barril
	añadir_puntos_con_combo(15)
	
	# Mostrar texto de barril roto
	mostrar_texto_flotante_en_posicion(
		"¡BARRIL ROTO!",
		Color(0.8, 0.4, 0),
		barril.position - Vector2(0, 40),
		24,
		randf_range(-0.1, 0.1)
	)
	
	# Sonido de barril roto
	Efectos.stream = preload("res://sounds/daño.mp3")
	Efectos.play()

func crear_efecto_rotura(posicion: Vector2):
	# Crear partículas para el efecto de rotura
	for i in range(12):
		var particula = Sprite2D.new()
		particula.texture = preload("res://images/heart pixel art 64x64.png")
		particula.scale = Vector2(0.15, 0.15)
		particula.position = posicion
		particula.modulate = Color(0.8, 0.4, 0)
		
		add_child(particula)
		
		var tween = create_tween()
		var angulo = randf_range(0, 2 * PI)
		var distancia = randf_range(30, 80)
		var direccion = Vector2(cos(angulo), sin(angulo)) * distancia
		
		tween.tween_property(particula, "position", posicion + direccion, 0.4)
		tween.parallel().tween_property(particula, "modulate:a", 0.0, 0.4)
		tween.parallel().tween_property(particula, "rotation", randf_range(-2, 2), 0.4)
		tween.tween_callback(particula.queue_free)

func actualizar_barriles_rotos(delta: float):
	# Actualizar animaciones de barriles rotos
	for i in range(barriles_rotos.size() - 1, -1, -1):
		var barril_roto = barriles_rotos[i]
		barril_roto["tiempo"] += delta
		
		if barril_roto["tiempo"] >= barril_roto["duracion"]:
			# Eliminar el barril completamente
			if is_instance_valid(barril_roto["barril"]):
				eliminar_barril(barril_roto["barril"])
			barriles_rotos.remove_at(i)

func aplicar_dano_por_barril():
	if invulnerable:
		return
	
	if vida == 1:
		vida -= 1
		textoVidas.text = "Vidas: " + str(vida)
		$pantallaMuerte.visible = true
	else:
		Efectos.stream = preload("res://sounds/daño.mp3")
		Efectos.play()
		vida -= 1
		textoVidas.text = "Vidas: " + str(vida)
		
		# Mostrar cuadrado rojo de daño
		mostrar_cuadrado_dano()
		
		# Resetear combo
		reset_combo()

# Asegúrate de que la función eliminar_barril esté así:
func eliminar_barril(barril):
	# Remover barril de la lista
	var index = barriles_en_camino.find(barril)
	if index != -1:
		barriles_en_camino.remove_at(index)
	
	# Destruir el barril
	if is_instance_valid(barril):
		barril.queue_free()


func _on_barril_sale_de_pantalla(barril: Node2D):
	eliminar_barril(barril)

func resetear_sistema_barriles():
	# Limpiar todos los barriles existentes
	for barril in barriles_en_camino:
		if is_instance_valid(barril):
			barril.queue_free()
	
	barriles_en_camino.clear()
	barriles_rotos.clear()
	barriles_generados = 0
	nivel_actual_barriles = 0
	tiempo_entre_barriles = 1.5
	
	# Reiniciar timer
	if timer_generacion_barriles:
		timer_generacion_barriles.stop()
	
	# Volver a inicializar
	inicializar_sistema_barriles()

# ============================================
# NUEVO: SISTEMA DE MEJORAS COMPLETO
# ============================================

func cargar_datos_guardados():
	print("📂 Cargando datos guardados...")
	
	# Cargar datos (se crearán automáticamente si no existen)
	SistemaGuardado.cargar_datos()
	
	monedas_totales = SistemaGuardado.obtener_monedas()
	print("💰 Monedas totales cargadas: ", monedas_totales)

func aplicar_mejoras_guardadas():
	print("⚡ Aplicando mejoras guardadas...")
	
	# Obtener todas las mejoras (sistema antiguo de compatibilidad)
	var mejoras_guardadas = SistemaGuardado.obtener_todas_mejoras()
	
	# Aplicar mejoras de vidas iniciales
	var vidas_extra = mejoras_guardadas.get("vidas_iniciales", 0)
	if vidas_extra > 0:
		vida += vidas_extra
		textoVidas.text = "Vidas: " + str(vida)
		print("❤️ Vidas extra: +", vidas_extra)
	
	# Aplicar mejoras de velocidad
	var velocidad_extra_valor = mejoras_guardadas.get("velocidad", 0)
	if velocidad_extra_valor > 0 and jugador.has_method("set_velocidad"):
		# Asumiendo que el jugador tiene una variable VELOCIDAD que podemos modificar
		if "VELOCIDAD" in jugador:
			jugador.VELOCIDAD += velocidad_extra_valor * 50
			print("⚡ Velocidad extra: +", velocidad_extra_valor * 50)
	
	# Aplicar mejoras de duración de poderes
	var duracion_extra = mejoras_guardadas.get("duracion_poderes", 0)
	if duracion_extra > 0:
		print("⏱️ Duración extra poderes (compatibilidad): +", duracion_extra)
	
	# Aplicar mejoras de imanes
	mejoras["imanes"] = mejoras_guardadas.get("imanes", 0)
	if mejoras["imanes"] > 0:
		print("🧲 Imanes disponibles: ", mejoras["imanes"])

func actualizar_duraciones_poderes():
	# Configurar tiempos iniciales basados en el sistema de guardado
	var duracion_escudo = SistemaGuardado.obtener_duracion_poder("escudo")
	var duracion_alas = SistemaGuardado.obtener_duracion_poder("alas")
	var duracion_zapatillas = SistemaGuardado.obtener_duracion_poder("zapatillas")
	
	if timer_escudo:
		timer_escudo.wait_time = duracion_escudo
		print("🛡️ Duración escudo: ", duracion_escudo, " segundos")
	
	if timer_ala:
		timer_ala.wait_time = duracion_alas
		print("🪽 Duración alas: ", duracion_alas, " segundos")
	
	if timer_zapa:
		timer_zapa.wait_time = duracion_zapatillas
		print("👟 Duración zapatillas: ", duracion_zapatillas, " segundos")
	
	# Configurar también el timer del imán con la duración del escudo
	if timer_iman:
		timer_iman.wait_time = duracion_escudo

func crear_objetos_por_tiempo(delta: float):
	# Calcular tiempo transcurrido
	var tiempo_transcurrido = tiempo_inicial - tiempo_restante
	
	# Crear monedas cada cierto tiempo (intervalo ajustable por dificultad)
	if tiempo_transcurrido - ultima_moneda_tiempo >= intervalo_monedas:
		crear_moneda_por_tiempo()
		ultima_moneda_tiempo = tiempo_transcurrido
	
	# Crear power-ups cada cierto tiempo
	if tiempo_transcurrido - ultimo_powerup_tiempo >= intervalo_powerups:
		crear_powerup_por_tiempo()
		ultimo_powerup_tiempo = tiempo_transcurrido

func crear_moneda_por_tiempo():
	var margen = 20
	var posicioAleatoria := randi_range(
		pared_izquierda.global_position.x + margen,
		pared_derecha.global_position.x - margen
	)
	
	var moneda = moneda_escena.instantiate()
	add_child(moneda)
	moneda.position = Vector2(posicioAleatoria, -50)
	
	moneda.connect("recogido", Callable(self, "_on_moneda_recogido_por_tiempo"))

func crear_powerup_por_tiempo():
	var margen = 20
	var posicioAleatoria := randi_range(
		pared_izquierda.global_position.x + margen,
		pared_derecha.global_position.x - margen
	)
	
	# Elegir power-up aleatorio
	var objeto = randi_range(1, 4)
	
	match objeto:
		1:
			var corazon_escena = preload("res://sprites/corazon.tscn")
			nCorazon = corazon_escena.instantiate()
			add_child(nCorazon)
			nCorazon.position = Vector2(posicioAleatoria, -50)
			nCorazon.connect("recogido", Callable(self, "_on_corazon_recogido"))
		2:
			var escudo_escena = preload("res://sprites/escudo.tscn")
			nEscudo = escudo_escena.instantiate()
			add_child(nEscudo)
			nEscudo.position = Vector2(posicioAleatoria, -50)
			nEscudo.connect("recogido", Callable(self, "_on_escudo_recogido"))
		3:
			var ala_escena = preload("res://sprites/ala.tscn")
			nAla = ala_escena.instantiate()
			add_child(nAla)
			nAla.position = Vector2(posicioAleatoria, -50)
			nAla.connect("recogido", Callable(self, "_on_ala_recogida"))
		4:
			var zapa_escena = preload("res://sprites/zapa.tscn")
			nZapa = zapa_escena.instantiate()
			add_child(nZapa)
			nZapa.position = Vector2(posicioAleatoria, -50)
			nZapa.connect("recogido", Callable(self, "_on_zapatilla_recogida"))

func _on_moneda_recogido():
	monedas += 1
	monedas_totales += 1
	
	# NUEVO: Guardar moneda inmediatamente
	SistemaGuardado.añadir_monedas(1)
	
	# Dar puntos por moneda (con combo)
	añadir_puntos_con_combo(5)
	
	# Mostrar partículas
	crear_particulas(jugador.position, Color(1, 1, 0), 15)
	
	# Sonido de moneda
	Efectos.stream = preload("res://sounds/8-bit-powerup-6768.mp3")
	Efectos.play()
	
	# Mostrar texto flotante
	var rotacion = randf_range(-0.2, 0.2)
	mostrar_texto_flotante_en_posicion(
		"+%d" % int(5 * combo_multiplier),
		Color(1, 1, 0),
		jugador.position - Vector2(0, 40),
		24,
		rotacion
	)
	
	if monedas_label:
		monedas_label.text = "Monedas: " + str(monedas)

func _on_moneda_recogido_por_tiempo():
	monedas += 1
	monedas_totales += 1
	
	SistemaGuardado.añadir_monedas(1)
	
	añadir_puntos_con_combo(10)
	
	crear_particulas(jugador.position, Color(1, 1, 0), 20)
	
	Efectos.stream = preload("res://sounds/8bit-sound-3-270296.mp3")
	Efectos.play()
	
	var rotacion = randf_range(-0.3, 0.3)
	mostrar_texto_flotante_en_posicion(
		"+%d TIEMPO" % int(10 * combo_multiplier),
		Color(1, 0.8, 0),
		jugador.position - Vector2(0, 40),
		26,
		rotacion
	)
	
	mostrar_texto_flotante_en_posicion(
		"+1 MONEDA ESPECIAL",
		Color(1, 1, 0.5),
		jugador.position - Vector2(0, 60),
		22,
		rotacion + 0.1
	)
	
	if monedas_label:
		monedas_label.text = "Monedas: " + str(monedas)

func actualizar_tiempo_display():
	var minutos = int(tiempo_restante) / 60
	var segundos = int(tiempo_restante) % 60
	var tiempo_formateado = "%02d:%02d" % [minutos, segundos]
	
	if tiempo_restante < 30:
		tiempotxt.add_theme_color_override("font_color", Color(1, 0, 0))
	elif tiempo_restante < 60:
		tiempotxt.add_theme_color_override("font_color", Color(1, 1, 0))
	else:
		tiempotxt.add_theme_color_override("font_color", Color(1, 1, 1))
	
	tiempotxt.text = "Tiempo: " + tiempo_formateado

func aumentar_dificultad_por_tiempo():
	nivel_dificultad += 1
	
	VELOCIDAD_BARRIL += 25
	
	max_cocos = min(8, max_cocos + 1)
	
	tiempo_entre_cocos = max(0.05, tiempo_entre_cocos - 0.05)
	
	intervalo_monedas = max(8.0, intervalo_monedas - 1.0)
	intervalo_powerups = max(15.0, intervalo_powerups - 1.5)
	
	var rotacion = randf_range(-0.1, 0.1)
	mostrar_texto_flotante_en_posicion(
		"NIVEL %d" % nivel_dificultad,
		Color(1, 0.5, 0),
		Vector2(get_viewport().size.x / 2, 150),
		32,
		rotacion
	)
	
	mostrar_texto_flotante_en_posicion(
		"¡DIFICULTAD AUMENTADA!",
		Color(1, 0, 0),
		Vector2(get_viewport().size.x / 2, 180),
		28,
		rotacion + 0.05
	)
	
	print("¡Dificultad aumentada! Nivel: ", nivel_dificultad)

func terminar_juego_por_tiempo():
	if juego_terminado:
		return
	
	juego_terminado = true
	tiempo_restante = 0
	
	# Detener generación de barriles
	if timer_generacion_barriles:
		timer_generacion_barriles.stop()
	
	print("🎮 TERMINANDO JUEGO ========================")
	print("  Puntos finales:", puntos)
	print("  Monedas recogidas en partida:", monedas)
	print("  Monedas totales antes:", SistemaGuardado.obtener_monedas())
	print("  Combo máximo:", max_combo)
	print("  Tiempo sobrevivido:", tiempo_inicial - tiempo_restante)
	
	var monedas_ganadas = 20 + int(puntos / 50)
	print("  Monedas ganadas (recompensa):", monedas_ganadas)
	
	var tiempo_sobrevivido = tiempo_inicial - tiempo_restante
	SistemaGuardado.guardar_ultima_partida(puntos, monedas_ganadas, tiempo_sobrevivido)
	
	SistemaGuardado.actualizar_max_combo(max_combo)
	
	SistemaGuardado.imprimir_datos()
	
	var pantalla_victoria = preload("res://Scenes/pantalla_victoria.tscn").instantiate()
	
	if pantalla_victoria.has_node("PuntosFinales"):
		pantalla_victoria.get_node("PuntosFinales").visible = false
	if pantalla_victoria.has_node("MonedasGanadas"):
		pantalla_victoria.get_node("MonedasGanadas").visible = false
	if pantalla_victoria.has_node("Victoria"):
		pantalla_victoria.get_node("Victoria").visible = false
	
	add_child(pantalla_victoria)
	
	get_tree().paused = true
	
	Efectos.stream = preload("res://sounds/8-bit-powerup-6768.mp3")
	Efectos.play()


func añadir_puntos_con_combo(cantidad: int):
	var ahora = Time.get_ticks_msec() / 1000.0
	
	# Si cantidad es 0, solo actualizar combo sin añadir puntos
	if cantidad > 0:
		if ahora - tiempo_ultimo_punto < combo_timeout:
			combo += 1
			max_combo = max(max_combo, combo)
			combo_multiplier = 1 + (combo * 0.1)
			puntos += int(cantidad * combo_multiplier)
			
			tiempo_desde_ultimo_combo = 0.0
			combo_fade_timer = 0.0
			
			mostrar_combo()
		else:
			combo = 1
			combo_multiplier = 1
			puntos += cantidad
	else:
		# Solo actualizar combo sin puntos
		if ahora - tiempo_ultimo_punto < combo_timeout:
			combo += 1
			max_combo = max(max_combo, combo)
			combo_multiplier = 1 + (combo * 0.1)
			
			tiempo_desde_ultimo_combo = 0.0
			combo_fade_timer = 0.0
			
			mostrar_combo()
		else:
			combo = 1
			combo_multiplier = 1
	
	tiempo_ultimo_punto = ahora
	
	if puntos_label:
		puntos_label.text = "Puntos: " + str(puntos)

func mostrar_combo():
	if combo > 1:
		if combo_label:
			combo_label.text = "COMBO x" + str(combo) + "!"
			combo_label.visible = true
			combo_label.modulate.a = 1.0
			combo_label.scale = Vector2(1.0, 1.0)
			
			var tween = create_tween()
			combo_label.scale = Vector2(0.5, 0.5)
			tween.tween_property(combo_label, "scale", Vector2(1.5, 1.5), 0.2)
			tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.2)
		
		var rotacion = randf_range(-0.1, 0.1)
		mostrar_texto_flotante_en_posicion(
			"COMBO x%d!" % combo,
			Color(1, 1, 0),
			jugador.position - Vector2(0, 80),
			28,
			rotacion
		)
		
		if combo_multiplier >= 1.5:
			mostrar_texto_flotante_en_posicion(
				"x%.1f MULTIPLICADOR" % combo_multiplier,
				Color(1, 0.5, 0),
				jugador.position - Vector2(0, 100),
				22,
				rotacion + 0.05
			)
		
		if combo >= 3:
			Efectos.stream = preload("res://sounds/8-bit-powerup-6768.mp3")
			Efectos.play()

func reset_combo():
	if combo > 1:
		crear_particulas(jugador.position, Color(1, 0, 0), 10)
		
		var rotacion = randf_range(-0.1, 0.1)
		mostrar_texto_flotante_en_posicion(
			"COMBO PERDIDO",
			Color(1, 0, 0),
			jugador.position - Vector2(0, 80),
			24,
			rotacion
		)
	
	combo = 0
	combo_multiplier = 1
	tiempo_desde_ultimo_combo = 0.0
	combo_fade_timer = 0.0
	
	if combo_label:
		combo_label.visible = false
		combo_label.modulate.a = 1.0
		combo_label.scale = Vector2(1.0, 1.0)

func mostrar_texto_flotante_en_posicion(texto: String, color: Color, posicion: Vector2, tamaño: int = 20, rotacion: float = 0.0):
	var label = Label.new()
	label.text = texto
	label.modulate = color
	label.position = posicion
	label.rotation = rotacion
	label.add_theme_font_size_override("font_size", tamaño)
	
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("outline_size", 1)
	
	add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position", posicion - Vector2(0, 40), 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)

func crear_particulas(posicion: Vector2, color: Color, cantidad: int = 20):
	for i in range(cantidad):
		var particula = Sprite2D.new()
		particula.texture = preload("res://images/heart pixel art 64x64.png")
		particula.scale = Vector2(0.1, 0.1)
		particula.position = posicion
		particula.modulate = color
		
		add_child(particula)
		
		var tween = create_tween()
		var direccion = Vector2(randf_range(-50, 50), randf_range(-50, -20))
		tween.tween_property(particula, "position", posicion + direccion, 0.3)
		tween.parallel().tween_property(particula, "modulate:a", 0.0, 0.3)
		tween.tween_callback(particula.queue_free)

func _on_particula_timer_timeout():
	if velocidad_extra and jugador and is_instance_valid(jugador):
		var particula = Sprite2D.new()
		var jugador_sprite = jugador.get_node_or_null("Sprite2D")
		if jugador_sprite and jugador_sprite.texture:
			particula.texture = jugador_sprite.texture
		particula.scale = Vector2(0.3, 0.3)
		particula.position = jugador.position
		particula.modulate = Color(1, 0.5, 1, 0.5)
		
		add_child(particula)
		
		var tween = create_tween()
		tween.tween_property(particula, "modulate:a", 0.0, 0.5)
		tween.tween_callback(particula.queue_free)

func atraer_items():
	var items = get_tree().get_nodes_in_group("items")
	for item in items:
		if is_instance_valid(item) and item != null:
			var direccion = (jugador.position - item.position).normalized()
			item.position += direccion * 200 * get_process_delta_time()

func _on_corazon_recogido():
	vida += 1
	textoVidas.text = "Vidas: " + str(vida)
	
	var rotacion = randf_range(-0.2, 0.2)
	mostrar_texto_flotante_en_posicion(
		"+1 VIDA",
		Color(1, 0, 0),
		jugador.position - Vector2(0, 40),
		24,
		rotacion
	)
	
	crear_particulas(jugador.position, Color(1, 0, 0), 20)

func _on_escudo_recogido():
	invulnerable = true
	
	var duracion_escudo = SistemaGuardado.obtener_duracion_poder("escudo")
	
	duracion.max_value = duracion_escudo
	duracion.value = duracion_escudo
	duracion.visible = true
	
	timer_escudo.wait_time = duracion_escudo
	timer_escudo.start()
	
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("escudo")
	var rotacion = randf_range(-0.2, 0.2)
	mostrar_texto_flotante_en_posicion(
		"ESCUDO NIVEL " + str(nivel_actual),
		Color(0, 0.5, 1),
		jugador.position - Vector2(0, 40),
		24,
		rotacion
	)
	
	mostrar_texto_flotante_en_posicion(
		str(duracion_escudo) + "s",
		Color(0.8, 0.9, 1),
		jugador.position - Vector2(0, 60),
		20,
		rotacion + 0.1
	)
	
	var jugador_sprite = jugador.get_node_or_null("Sprite2D")
	if jugador_sprite:
		jugador_sprite.modulate = Color(0.5, 0.8, 1)
	crear_particulas(jugador.position, Color(0, 0.5, 1), 30)

func _on_ala_recogida():
	doble_salto = true
	
	var duracion_alas = SistemaGuardado.obtener_duracion_poder("alas")
	
	duracion.max_value = duracion_alas
	duracion.value = duracion_alas
	duracion.visible = true
	
	timer_ala.wait_time = duracion_alas
	timer_ala.start()
	
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("alas")
	var rotacion = randf_range(-0.2, 0.2)
	mostrar_texto_flotante_en_posicion(
		"ALAS NIVEL " + str(nivel_actual),
		Color(1, 1, 0),
		jugador.position - Vector2(0, 40),
		24,
		rotacion
	)
	
	mostrar_texto_flotante_en_posicion(
		str(duracion_alas) + "s",
		Color(1, 1, 0.5),
		jugador.position - Vector2(0, 60),
		20,
		rotacion + 0.1
	)
	
	crear_particulas(jugador.position, Color(1, 1, 0), 25)

func _on_zapatilla_recogida():
	velocidad_extra = true
	
	var duracion_zapatillas = SistemaGuardado.obtener_duracion_poder("zapatillas")
	
	duracion.max_value = duracion_zapatillas
	duracion.value = duracion_zapatillas
	duracion.visible = true
	
	timer_zapa.wait_time = duracion_zapatillas
	timer_zapa.start()
	
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("zapatillas")
	var rotacion = randf_range(-0.2, 0.2)
	mostrar_texto_flotante_en_posicion(
		"ZAPATILLAS NIVEL " + str(nivel_actual),
		Color(1, 0.5, 1),
		jugador.position - Vector2(0, 40),
		24,
		rotacion
	)
	
	mostrar_texto_flotante_en_posicion(
		str(duracion_zapatillas) + "s",
		Color(1, 0.7, 1),
		jugador.position - Vector2(0, 60),
		20,
		rotacion + 0.1
	)
	
	var jugador_sprite = jugador.get_node_or_null("Sprite2D")
	if jugador_sprite:
		jugador_sprite.modulate = Color(1, 0.5, 1)

func _on_iman_recogido():
	iman_activado = true
	
	var duracion_iman = SistemaGuardado.obtener_duracion_poder("escudo")
	
	duracion.max_value = duracion_iman
	duracion.value = duracion_iman
	duracion.visible = true
	
	timer_iman.wait_time = duracion_iman
	timer_iman.start()
	
	var jugador_sprite = jugador.get_node_or_null("Sprite2D")
	if jugador_sprite:
		jugador_sprite.modulate = Color(0.5, 1, 0.5)
	crear_particulas(jugador.position, Color(0, 1, 0), 30)

func _fin_escudo():
	invulnerable = false
	duracion.visible = false
	var jugador_sprite = jugador.get_node_or_null("Sprite2D")
	if jugador_sprite:
		jugador_sprite.modulate = Color(1, 1, 1)

func _fin_ala():
	doble_salto = false
	duracion.visible = false

func _fin_zapatilla():
	velocidad_extra = false
	duracion.visible = false
	var jugador_sprite = jugador.get_node_or_null("Sprite2D")
	if jugador_sprite:
		jugador_sprite.modulate = Color(1, 1, 1)

func _fin_iman():
	iman_activado = false
	duracion.visible = false
	var jugador_sprite = jugador.get_node_or_null("Sprite2D")
	if jugador_sprite:
		jugador_sprite.modulate = Color(1, 1, 1)

func _on_viewport_resized():
	pantalla_ancho = get_viewport().size.x

func _input(event):
	if event.is_action_pressed("Reiniciar"):
		get_tree().change_scene_to_file("res://Scenes/juego_2.tscn")
	
	if event.is_action_pressed("ui_accept") and mejoras["imanes"] > 0:
		_on_iman_recogido()
		mejoras["imanes"] -= 1

func crear_coco():
	if cocos_en_pantalla >= max_cocos:
		return

	var margen = 20
	var posicioAleatoria := randi_range(
		pared_izquierda.global_position.x + margen,
		pared_derecha.global_position.x - margen
	)

	var escena_coco = preload("res://sprites/coco.tscn")
	var nCoco = escena_coco.instantiate()
	add_child(nCoco)
	cocos_en_pantalla += 1
	
	nCoco.position = Vector2(posicioAleatoria, -50)
	nCoco.tree_exited.connect(func(): cocos_en_pantalla -= 1)

# Modifica la función detecta() para manejar la colisión con barriles:
func detecta(body):
	# Verificar si es un barril
	if body is Area2D and body.has_method("romper"):
		# Si es un barril y no estamos invulnerables
		if not invulnerable:
			# Verificar que el barril no esté ya roto
			if not body.esta_roto:
				# Romper el barril
				body.romper()
				
				# Aplicar daño al jugador
				aplicar_dano_por_barril()
				
				# Puntos por romper barril CON COMBO
				añadir_puntos_con_combo(15)  # Esto manejará el combo
				
				# Mostrar texto de barril roto
				mostrar_texto_flotante_en_posicion(
					"¡BARRIL ROTO!",
					Color(0.8, 0.4, 0),
					body.position - Vector2(0, 40),
					24,
					randf_range(-0.1, 0.1)
				)
				
				# Sonido de barril roto
				Efectos.stream = preload("res://sounds/daño.mp3")
				Efectos.play()
				
				# Remover de la lista
				var index = barriles_en_camino.find(body)
				if index != -1:
					barriles_en_camino.remove_at(index)
		else:
			# Si estamos invulnerables, solo rompemos el barril
			if not body.esta_roto:
				body.romper()
				# Puntos por romper barril CON COMBO (sin daño)
				añadir_puntos_con_combo(15)
		return
	
	# Resto del código original para otros objetos...
	if body.has_method("_on_moneda_recogido") or "coin" in body.name.to_lower():
		return
	
	if body == nCorazon or body == nEscudo or body == nAla or body == nZapa:
		Efectos.stream = preload("res://sounds/8-bit-powerup-6768.mp3")
		Efectos.play()
		return

	if invulnerable:
		return

	if vida == 1:
		vida -= 1
		textoVidas.text = "Vidas: " + str(vida)
		$pantallaMuerte.visible = true
	else:
		Efectos.stream = preload("res://sounds/daño.mp3")
		Efectos.play()
		vida -= 1
		textoVidas.text = "Vidas: " + str(vida)
		
		mostrar_cuadrado_dano()
		
		reset_combo()


func mostrar_cuadrado_dano():
	var flash_rojo = ColorRect.new()
	flash_rojo.name = "FlashDano"
	flash_rojo.color = Color(1, 0, 0, 0.3)
	flash_rojo.size = get_viewport().size
	flash_rojo.position = Vector2(0, 0)
	
	add_child(flash_rojo)
	
	var tween = create_tween()
	tween.tween_property(flash_rojo, "color:a", 0.0, 0.3)
	tween.tween_callback(flash_rojo.queue_free)

func cargar_mejoras():
	mejoras = {
		"vidas_iniciales": 0,
		"velocidad": 0,
		"duracion_poderes": 0,
		"imanes": 0
	}

func _on_pantalla_muerte_visibility_changed() -> void:
	get_tree().paused = not get_tree().paused
	GlobalAudio.stream = preload("res://sounds/game-over.mp3")
	GlobalAudio.play()

func iniciar_poder_temporal():
	duracion.max_value = 5.0
	duracion.value = 5.0
	duracion.visible = true

	if invulnerabilidad_timer == null:
		invulnerabilidad_timer = Timer.new()
		invulnerabilidad_timer.wait_time = 5.0
		invulnerabilidad_timer.one_shot = true
		invulnerabilidad_timer.timeout.connect(_fin_poderes)
		add_child(invulnerabilidad_timer)

	invulnerabilidad_timer.start()

func _fin_poderes():
	invulnerable = false
	doble_salto = false
	velocidad_extra = false
	duracion.visible = false
