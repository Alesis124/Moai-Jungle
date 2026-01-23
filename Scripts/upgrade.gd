extends CanvasLayer

@onready var mejoras = $Texto_mejoras
@onready var aviso = $Level_up

# Colores definidos
var COLOR_ACTIVO = Color(0.2, 0.8, 0.2)  # Verde para nivel activo
var COLOR_DESBLOQUEADO_VERDE_CLARO = Color(0.4, 0.9, 0.4, 0.7)  # Verde clarito para niveles inferiores desbloqueados
var COLOR_DESBLOQUEADO_GRIS_CLARO = Color(0.7, 0.7, 0.7, 0.8)  # Gris claro para niveles superiores desbloqueados
var COLOR_BLOQUEADO = Color(0.3, 0.3, 0.3, 0.6)  # Gris oscuro para bloqueado

# Arrays para organizar las referencias
var rectangulos_escudo = []
var rectangulos_alas = []
var rectangulos_zapatillas = []

# Escudo
@onready var menos_escudo = $Panel_escudo/menos_escudo
@onready var escudo_lvl1 = $Panel_escudo/escudo_lvl1
@onready var escudo_lvl2 = $Panel_escudo/escudo_lvl2
@onready var escudo_lvl3 = $Panel_escudo/escudo_lvl3
@onready var escudo_lvl4 = $Panel_escudo/escudo_lvl4
@onready var escudo_lvl5 = $Panel_escudo/escudo_lvl5
@onready var escudo_lvl6 = $Panel_escudo/escudo_lvl6
@onready var escudo_lvl7 = $Panel_escudo/escudo_lvl7
@onready var mas_escudo = $Panel_escudo/mas_escudo
@onready var subir_nvl_escudo = $Panel_escudo/subir_lvl_escudo
@onready var precio_escudo = $Panel_escudo/precio_escudo

# Alas
@onready var menos_alas = $Panel_alas/menos_alas
@onready var alas_lvl1 = $Panel_alas/alas_lvl1
@onready var alas_lvl2 = $Panel_alas/alas_lvl2
@onready var alas_lvl3 = $Panel_alas/alas_lvl3
@onready var alas_lvl4 = $Panel_alas/alas_lvl4
@onready var alas_lvl5 = $Panel_alas/alas_lvl5
@onready var alas_lvl6 = $Panel_alas/alas_lvl6
@onready var alas_lvl7 = $Panel_alas/alas_lvl7
@onready var mas_alas = $Panel_alas/mas_alas
@onready var subir_nvl_alas = $Panel_alas/subir_lvl_alas
@onready var precio_alas = $Panel_alas/precio_alas

# Zapatillas
@onready var menos_zapatillas = $Panel_zapatillas/menos_zapatillas
@onready var zapatillas_lvl1 = $Panel_zapatillas/zapatillas_lvl1
@onready var zapatillas_lvl2 = $Panel_zapatillas/zapatillas_lvl2
@onready var zapatillas_lvl3 = $Panel_zapatillas/zapatillas_lvl3
@onready var zapatillas_lvl4 = $Panel_zapatillas/zapatillas_lvl4
@onready var zapatillas_lvl5 = $Panel_zapatillas/zapatillas_lvl5
@onready var zapatillas_lvl6 = $Panel_zapatillas/zapatillas_lvl6
@onready var zapatillas_lvl7 = $Panel_zapatillas/zapatillas_lvl7
@onready var mas_zapatillas = $Panel_zapatillas/mas_zapatillas
@onready var subir_nvl_zapatillas = $Panel_zapatillas/subir_lvl_zapatillas
@onready var precio_zapatillas = $Panel_zapatillas/precio_zapatillas

# Timer para animación arcoíris
var rainbow_timer = 0.0
var rainbow_speed = 5.0  # Velocidad del cambio de color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Inicializar arrays de rectángulos
	rectangulos_escudo = [escudo_lvl1, escudo_lvl2, escudo_lvl3, escudo_lvl4, 
						 escudo_lvl5, escudo_lvl6, escudo_lvl7]
	
	rectangulos_alas = [alas_lvl1, alas_lvl2, alas_lvl3, alas_lvl4,
					   alas_lvl5, alas_lvl6, alas_lvl7]
	
	rectangulos_zapatillas = [zapatillas_lvl1, zapatillas_lvl2, zapatillas_lvl3, zapatillas_lvl4,
							 zapatillas_lvl5, zapatillas_lvl6, zapatillas_lvl7]
	
	# Conectar señales de botones
	conectar_botones()
	
	# Cargar datos y actualizar UI
	SistemaGuardado.cargar_datos()
	actualizar_toda_la_ui()
	
	# Ocultar el texto Level Up inicialmente
	if aviso:
		aviso.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Animación arcoíris para el texto Level Up si está visible
	if aviso and aviso.visible:
		rainbow_timer += delta * rainbow_speed
		
		# Crear color arcoíris que cambia con el tiempo
		var hue = fmod(rainbow_timer, 1.0)
		var rainbow_color = Color.from_hsv(hue, 0.8, 1.0)
		
		# Aplicar el color con un poco de brillo
		aviso.modulate = rainbow_color
		
		# También animar el tamaño (crece y luego vuelve)
		var scale_factor = 1.0 + sin(rainbow_timer * 2.0) * 0.1
		aviso.scale = Vector2(scale_factor, scale_factor)

# ============================================
# FUNCIONES DE CONEXIÓN DE BOTONES - AÑADIDA
# ============================================

func conectar_botones():
	# Escudo
	if menos_escudo:
		menos_escudo.pressed.connect(_on_menos_escudo_pressed)
	if mas_escudo:
		mas_escudo.pressed.connect(_on_mas_escudo_pressed)
	if subir_nvl_escudo:
		subir_nvl_escudo.pressed.connect(_on_subir_nvl_escudo_pressed)
	
	# Alas
	if menos_alas:
		menos_alas.pressed.connect(_on_menos_alas_pressed)
	if mas_alas:
		mas_alas.pressed.connect(_on_mas_alas_pressed)
	if subir_nvl_alas:
		subir_nvl_alas.pressed.connect(_on_subir_nvl_alas_pressed)
	
	# Zapatillas
	if menos_zapatillas:
		menos_zapatillas.pressed.connect(_on_menos_zapatillas_pressed)
	if mas_zapatillas:
		mas_zapatillas.pressed.connect(_on_mas_zapatillas_pressed)
	if subir_nvl_zapatillas:
		subir_nvl_zapatillas.pressed.connect(_on_subir_nvl_zapatillas_pressed)

# ============================================
# FUNCIONES DE ACTUALIZACIÓN DE UI (CORREGIDAS)
# ============================================

func actualizar_toda_la_ui():
	# NUEVO: Siempre cargar datos frescos antes de actualizar
	SistemaGuardado.cargar_datos()
	
	actualizar_ui_escudo()
	actualizar_ui_alas()
	actualizar_ui_zapatillas()
	
	# Actualizar monedas en todas las secciones
	var monedas = SistemaGuardado.obtener_monedas()
	if mejoras:
		mejoras.text = "MEJORAS\nMonedas: " + str(monedas)
	
	# Actualizar precios de todos los poderes
	actualizar_precios()

func actualizar_ui_escudo():
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("escudo")
	var nivel_desbloqueado = SistemaGuardado.obtener_nivel_desbloqueado("escudo")
	
	print("🛡️ Escudo - Nivel actual:", nivel_actual, " Desbloqueado hasta:", nivel_desbloqueado)
	
	# Actualizar colores de rectángulos - LÓGICA CORREGIDA
	for i in range(7):
		var rectangulo = rectangulos_escudo[i]
		var nivel_rect = i + 1
		
		if rectangulo:
			# Nivel 1 siempre está activo (verde) aunque no sea el nivel actual seleccionado
			if nivel_rect == 1:
				rectangulo.modulate = COLOR_ACTIVO
				rectangulo.visible = true
			elif nivel_rect == nivel_actual:
				# Nivel actual activo (no es el 1) - VERDE
				rectangulo.modulate = COLOR_ACTIVO
				rectangulo.visible = true
			elif nivel_rect <= nivel_actual:
				# Niveles inferiores al actual (2, 3 si actual es 4) - VERDE CLARITO
				rectangulo.modulate = COLOR_DESBLOQUEADO_VERDE_CLARO
				rectangulo.visible = true
			elif nivel_rect <= nivel_desbloqueado:
				# Niveles superiores desbloqueados pero no activos - GRIS CLARO
				rectangulo.modulate = COLOR_DESBLOQUEADO_GRIS_CLARO
				rectangulo.visible = true
			else:
				# Nivel bloqueado - GRIS OSCURO
				rectangulo.modulate = COLOR_BLOQUEADO
				rectangulo.visible = true
	
	# Actualizar estado de botones
	if mas_escudo:
		mas_escudo.disabled = (nivel_actual >= nivel_desbloqueado)
	
	if menos_escudo:
		menos_escudo.disabled = (nivel_actual <= 1)

func actualizar_ui_alas():
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("alas")
	var nivel_desbloqueado = SistemaGuardado.obtener_nivel_desbloqueado("alas")
	
	print("🪽 Alas - Nivel actual:", nivel_actual, " Desbloqueado hasta:", nivel_desbloqueado)
	
	# Actualizar colores de rectángulos - LÓGICA CORREGIDA
	for i in range(7):
		var rectangulo = rectangulos_alas[i]
		var nivel_rect = i + 1
		
		if rectangulo:
			# Nivel 1 siempre está activo (verde) aunque no sea el nivel actual seleccionado
			if nivel_rect == 1:
				rectangulo.modulate = COLOR_ACTIVO
				rectangulo.visible = true
			elif nivel_rect == nivel_actual:
				# Nivel actual activo (no es el 1) - VERDE
				rectangulo.modulate = COLOR_ACTIVO
				rectangulo.visible = true
			elif nivel_rect <= nivel_actual:
				# Niveles inferiores al actual (2, 3 si actual es 4) - VERDE CLARITO
				rectangulo.modulate = COLOR_DESBLOQUEADO_VERDE_CLARO
				rectangulo.visible = true
			elif nivel_rect <= nivel_desbloqueado:
				# Niveles superiores desbloqueados pero no activos - GRIS CLARO
				rectangulo.modulate = COLOR_DESBLOQUEADO_GRIS_CLARO
				rectangulo.visible = true
			else:
				# Nivel bloqueado - GRIS OSCURO
				rectangulo.modulate = COLOR_BLOQUEADO
				rectangulo.visible = true
	
	# Actualizar estado de botones
	if mas_alas:
		mas_alas.disabled = (nivel_actual >= nivel_desbloqueado)
	
	if menos_alas:
		menos_alas.disabled = (nivel_actual <= 1)

func actualizar_ui_zapatillas():
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("zapatillas")
	var nivel_desbloqueado = SistemaGuardado.obtener_nivel_desbloqueado("zapatillas")
	
	print("👟 Zapatillas - Nivel actual:", nivel_actual, " Desbloqueado hasta:", nivel_desbloqueado)
	
	# Actualizar colores de rectángulos - LÓGICA CORREGIDA
	for i in range(7):
		var rectangulo = rectangulos_zapatillas[i]
		var nivel_rect = i + 1
		
		if rectangulo:
			# Nivel 1 siempre está activo (verde) aunque no sea el nivel actual seleccionado
			if nivel_rect == 1:
				rectangulo.modulate = COLOR_ACTIVO
				rectangulo.visible = true
			elif nivel_rect == nivel_actual:
				# Nivel actual activo (no es el 1) - VERDE
				rectangulo.modulate = COLOR_ACTIVO
				rectangulo.visible = true
			elif nivel_rect <= nivel_actual:
				# Niveles inferiores al actual (2, 3 si actual es 4) - VERDE CLARITO
				rectangulo.modulate = COLOR_DESBLOQUEADO_VERDE_CLARO
				rectangulo.visible = true
			elif nivel_rect <= nivel_desbloqueado:
				# Niveles superiores desbloqueados pero no activos - GRIS CLARO
				rectangulo.modulate = COLOR_DESBLOQUEADO_GRIS_CLARO
				rectangulo.visible = true
			else:
				# Nivel bloqueado - GRIS OSCURO
				rectangulo.modulate = COLOR_BLOQUEADO
				rectangulo.visible = true
	
	# Actualizar estado de botones
	if mas_zapatillas:
		mas_zapatillas.disabled = (nivel_actual >= nivel_desbloqueado)
	
	if menos_zapatillas:
		menos_zapatillas.disabled = (nivel_actual <= 1)

# NUEVO: Función para actualizar precios
func actualizar_precios():
	# Actualizar precio del escudo
	var precio_escudo_sig = SistemaGuardado.obtener_precio_siguiente_nivel("escudo")
	if precio_escudo:
		if precio_escudo_sig > 0:
			precio_escudo.text = "Precio: " + str(precio_escudo_sig) + " monedas"
			if subir_nvl_escudo:
				subir_nvl_escudo.disabled = false
		else:
			precio_escudo.text = "NIVEL MÁXIMO"
			if subir_nvl_escudo:
				subir_nvl_escudo.disabled = true
	
	# Actualizar precio de las alas
	var precio_alas_sig = SistemaGuardado.obtener_precio_siguiente_nivel("alas")
	if precio_alas:
		if precio_alas_sig > 0:
			precio_alas.text = "Precio: " + str(precio_alas_sig) + " monedas"
			if subir_nvl_alas:
				subir_nvl_alas.disabled = false
		else:
			precio_alas.text = "NIVEL MÁXIMO"
			if subir_nvl_alas:
				subir_nvl_alas.disabled = true
	
	# Actualizar precio de las zapatillas
	var precio_zapatillas_sig = SistemaGuardado.obtener_precio_siguiente_nivel("zapatillas")
	if precio_zapatillas:
		if precio_zapatillas_sig > 0:
			precio_zapatillas.text = "Precio: " + str(precio_zapatillas_sig) + " monedas"
			if subir_nvl_zapatillas:
				subir_nvl_zapatillas.disabled = false
		else:
			precio_zapatillas.text = "NIVEL MÁXIMO"
			if subir_nvl_zapatillas:
				subir_nvl_zapatillas.disabled = true

# ============================================
# FUNCIONES PARA ESCUDO
# ============================================

func _on_menos_escudo_pressed():
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("escudo")
	if nivel_actual > 1:
		SistemaGuardado.cambiar_nivel_actual("escudo", nivel_actual - 1)
		actualizar_toda_la_ui()

func _on_mas_escudo_pressed():
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("escudo")
	var nivel_desbloqueado = SistemaGuardado.obtener_nivel_desbloqueado("escudo")
	
	if nivel_actual < nivel_desbloqueado:
		SistemaGuardado.cambiar_nivel_actual("escudo", nivel_actual + 1)
		actualizar_toda_la_ui()

func _on_subir_nvl_escudo_pressed():
	var nivel_desbloqueado = SistemaGuardado.obtener_nivel_desbloqueado("escudo")
	var precio = SistemaGuardado.obtener_precio_siguiente_nivel("escudo")
	
	if precio > 0:
		if SistemaGuardado.mejorar_poder("escudo", precio):
			mostrar_level_up("ESCUDO NIVEL " + str(nivel_desbloqueado + 1))
			actualizar_toda_la_ui()
		else:
			mostrar_mensaje_error("No tienes suficientes monedas")

# ============================================
# FUNCIONES PARA ALAS
# ============================================

func _on_menos_alas_pressed():
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("alas")
	if nivel_actual > 1:
		SistemaGuardado.cambiar_nivel_actual("alas", nivel_actual - 1)
		actualizar_toda_la_ui()

func _on_mas_alas_pressed():
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("alas")
	var nivel_desbloqueado = SistemaGuardado.obtener_nivel_desbloqueado("alas")
	
	if nivel_actual < nivel_desbloqueado:
		SistemaGuardado.cambiar_nivel_actual("alas", nivel_actual + 1)
		actualizar_toda_la_ui()

func _on_subir_nvl_alas_pressed():
	var nivel_desbloqueado = SistemaGuardado.obtener_nivel_desbloqueado("alas")
	var precio = SistemaGuardado.obtener_precio_siguiente_nivel("alas")
	
	if precio > 0:
		if SistemaGuardado.mejorar_poder("alas", precio):
			mostrar_level_up("ALAS NIVEL " + str(nivel_desbloqueado + 1))
			actualizar_toda_la_ui()
		else:
			mostrar_mensaje_error("No tienes suficientes monedas")

# ============================================
# FUNCIONES PARA ZAPATILLAS
# ============================================

func _on_menos_zapatillas_pressed():
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("zapatillas")
	if nivel_actual > 1:
		SistemaGuardado.cambiar_nivel_actual("zapatillas", nivel_actual - 1)
		actualizar_toda_la_ui()

func _on_mas_zapatillas_pressed():
	var nivel_actual = SistemaGuardado.obtener_nivel_actual("zapatillas")
	var nivel_desbloqueado = SistemaGuardado.obtener_nivel_desbloqueado("zapatillas")
	
	if nivel_actual < nivel_desbloqueado:
		SistemaGuardado.cambiar_nivel_actual("zapatillas", nivel_actual + 1)
		actualizar_toda_la_ui()

func _on_subir_nvl_zapatillas_pressed():
	var nivel_desbloqueado = SistemaGuardado.obtener_nivel_desbloqueado("zapatillas")
	var precio = SistemaGuardado.obtener_precio_siguiente_nivel("zapatillas")
	
	if precio > 0:
		if SistemaGuardado.mejorar_poder("zapatillas", precio):
			mostrar_level_up("ZAPATILLAS NIVEL " + str(nivel_desbloqueado + 1))
			actualizar_toda_la_ui()
		else:
			mostrar_mensaje_error("No tienes suficientes monedas")

# ============================================
# FUNCIONES DE ANIMACIÓN Y EFECTOS
# ============================================

func mostrar_level_up(texto: String):
	if aviso:
		aviso.text = texto
		aviso.visible = true
		aviso.scale = Vector2(1.0, 1.0)
		aviso.modulate.a = 1.0
		
		var tween = create_tween()
		tween.tween_property(aviso, "scale", Vector2(1.3, 1.3), 0.3)
		tween.parallel().tween_property(aviso, "position:y", aviso.position.y - 50, 0.3)
		tween.tween_interval(1.0)
		tween.tween_property(aviso, "modulate:a", 0.0, 0.5)
		tween.tween_callback(func(): aviso.visible = false)
		
		var efecto_sonido = AudioStreamPlayer.new()
		efecto_sonido.stream = preload("res://sounds/8-bit-powerup-6768.mp3")
		add_child(efecto_sonido)
		efecto_sonido.play()
		efecto_sonido.finished.connect(func(): efecto_sonido.queue_free())

func mostrar_mensaje_error(mensaje: String):
	var error_label = Label.new()
	error_label.text = mensaje
	error_label.add_theme_font_size_override("font_size", 20)
	error_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	error_label.position = Vector2(get_viewport().size.x / 2 - 100, get_viewport().size.y / 2)
	add_child(error_label)
	
	var tween = create_tween()
	tween.tween_property(error_label, "position:y", error_label.position.y - 30, 0.5)
	tween.parallel().tween_property(error_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(error_label.queue_free)

# ============================================
# FUNCIÓN DE NAVEGACIÓN
# ============================================

func _on_btn_back_pressed() -> void:
	SistemaGuardado.guardar_datos()
	get_tree().change_scene_to_file("res://Scenes/seleccion_videojuego.tscn")
