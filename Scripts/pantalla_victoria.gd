extends CanvasLayer

var entra = false
@onready var puntos_label = $PuntosFinales
@onready var record_label = $PuntosFinales/Record
@onready var victoria_label = $Victoria
@onready var monedas_label = $MonedasGanadas
@onready var btn_reintentar = $btn_reintentar
@onready var btn_salir = $btn_salir

# Variables para animaciones
var puntos_actuales = 0
var puntos_finales = 0
var puntos_record_anterior = 0
var monedas_actuales = 0
var monedas_finales = 0
var animando_puntos = false
var animando_monedas = false
var nuevo_record = false

# Variables para efectos especiales
var tiempo_arcoiris = 0.0
var tiempo_record = 0.0
var colores_arcoiris = [
	Color(1, 0, 0),      # Rojo
	Color(1, 0.5, 0),    # Naranja
	Color(1, 1, 0),      # Amarillo
	Color(0, 1, 0),      # Verde
	Color(0, 0.5, 1),    # Azul claro
	Color(0.5, 0, 1),    # Violeta
	Color(1, 0, 1)       # Rosa
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entra = false
	
	# Inicialmente ocultar botones
	btn_reintentar.visible = false
	btn_salir.visible = false
	record_label.visible = false
	
	# Ocultar elementos que se animarán
	victoria_label.scale = Vector2.ZERO
	puntos_label.scale = Vector2.ZERO
	monedas_label.scale = Vector2.ZERO
	
	# Cargar datos del juego
	cargar_datos_juego()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Efecto arcoiris para "VICTORIA"
	if victoria_label.visible and victoria_label.modulate.a > 0:
		tiempo_arcoiris += delta * 2.0  # Velocidad del arcoiris
		var color_index = int(tiempo_arcoiris) % colores_arcoiris.size()
		var next_color_index = (color_index + 1) % colores_arcoiris.size()
		var t = fmod(tiempo_arcoiris, 1.0)
		
		# Interpolar entre colores
		victoria_label.modulate = colores_arcoiris[color_index].lerp(
			colores_arcoiris[next_color_index], t
		)
	
	# Efecto de pulso infinito para "NUEVO RÉCORD"
	if record_label.visible and record_label.modulate.a > 0:
		tiempo_record += delta * 1.5
		var pulso = sin(tiempo_record * 2.0) * 0.3 + 1.3  # Oscila entre 1.0 y 1.6
		record_label.scale = Vector2(pulso, pulso)
		
		# También cambiar color dorado dinámico
		var brillo = sin(tiempo_record * 3.0) * 0.3 + 0.7
		record_label.modulate = Color(1, 0.8 + brillo * 0.2, 0.3 + brillo * 0.3)

func cargar_datos_juego():
	print("🎮 Cargando datos de la última partida...")
	
	# Obtener datos de la última partida
	var datos_ultima_partida = SistemaGuardado.obtener_ultima_partida()
	
	# Obtener récord anterior (máximo puntos)
	puntos_record_anterior = SistemaGuardado.obtener_max_puntos()
	
	# Usar datos REALES de la última partida
	puntos_finales = datos_ultima_partida["puntos"]
	monedas_finales = datos_ultima_partida["monedas_ganadas"]
	nuevo_record = datos_ultima_partida["nuevo_record"]
	var tiempo_sobrevivido = datos_ultima_partida["tiempo_sobrevivido"]
	
	print("📊 Datos REALES de la partida:")
	print("  Puntos finales:", puntos_finales)
	print("  Monedas ganadas:", monedas_finales)
	print("  Record anterior:", puntos_record_anterior)
	print("  Nuevo record:", nuevo_record)
	print("  Tiempo sobrevivido:", tiempo_sobrevivido)
	
	# Verificar que tenemos datos válidos
	if puntos_finales <= 0:
		print("⚠️ Advertencia: Puntos finales es 0 o negativo, usando valor mínimo")
		puntos_finales = 1
	
	if monedas_finales < 0:
		print("⚠️ Advertencia: Monedas ganadas es negativo, ajustando a 0")
		monedas_finales = 0
	
	# Mostrar tiempo sobrevivido si existe el label
	if has_node("TiempoSobrevivido"):
		var minutos = int(tiempo_sobrevivido) / 60
		var segundos = int(tiempo_sobrevivido) % 60
		get_node("TiempoSobrevivido").text = "Tiempo: %02d:%02d" % [minutos, segundos]
	
	# Iniciar secuencia de animaciones
	iniciar_animaciones()

func iniciar_animaciones():
	# Secuencia: 1. Victoria, 2. Puntos, 3. Monedas, 4. Botones
	var secuencia = create_tween()
	
	# 1. Victoria aparece con efecto
	secuencia.tween_callback(func(): mostrar_victoria())
	secuencia.tween_interval(1.0)
	
	# 2. Puntos aparecen y se cuentan
	secuencia.tween_callback(func(): mostrar_puntos())
	secuencia.tween_interval(2.0)
	
	# 3. Monedas aparecen y se cuentan
	secuencia.tween_callback(func(): mostrar_monedas())
	secuencia.tween_interval(1.5)
	
	# 4. Mostrar botones
	secuencia.tween_callback(func(): mostrar_botones())

func mostrar_victoria():
	if not victoria_label:
		return
	
	victoria_label.visible = true
	victoria_label.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	
	# Efecto de entrada más dramático
	tween.tween_property(victoria_label, "scale", Vector2(1.5, 1.5), 1.0)
	tween.parallel().tween_property(victoria_label, "modulate:a", 1.0, 0.8)
	
	# Efecto de rebote
	tween.tween_property(victoria_label, "scale", Vector2(1.2, 1.2), 0.5)
	
	# Iniciar efecto arcoiris (se maneja en _process)
	print("🌈 Efecto arcoiris activado para VICTORIA")

func mostrar_puntos():
	if not puntos_label:
		return
	
	puntos_label.visible = true
	puntos_label.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Aparece con efecto elástico
	tween.tween_property(puntos_label, "scale", Vector2(1.0, 1.0), 0.8)
	tween.parallel().tween_property(puntos_label, "modulate:a", 1.0, 0.6)
	
	# Contar puntos
	tween.tween_callback(func(): animar_contador_puntos())

func animar_contador_puntos():
	if not puntos_label:
		return
	
	animando_puntos = true
	puntos_actuales = 0
	
	# Crear tween para contar
	var tween = create_tween()
	var duracion = min(3.0, max(1.0, puntos_finales / 500.0))  # Ajustar duración según puntos
	
	tween.tween_method(Callable(self, "actualizar_contador_puntos"), 0, puntos_finales, duracion)
	tween.tween_callback(func(): 
		animando_puntos = false
		# Si hay nuevo record, mostrar animación especial
		if nuevo_record and record_label:
			mostrar_nuevo_record()
	)
	
	# Efecto de sonido para contar puntos
	Efectos.stream = preload("res://sounds/8-bit-powerup-6768.mp3")
	Efectos.volume_db = -10
	Efectos.play()

func actualizar_contador_puntos(valor: float):
	if not puntos_label:
		return
	
	puntos_actuales = int(valor)
	puntos_label.text = "Puntos: " + str(puntos_actuales)
	
	# Efecto visual más pronunciado
	if int(valor) % 50 == 0:  # Cada 50 puntos
		var mini_tween = create_tween()
		mini_tween.tween_property(puntos_label, "scale", Vector2(1.1, 1.1), 0.15)
		mini_tween.parallel().tween_property(puntos_label, "modulate", Color(1, 1, 0.8), 0.1)
		mini_tween.tween_property(puntos_label, "scale", Vector2(1.0, 1.0), 0.15)
		mini_tween.parallel().tween_property(puntos_label, "modulate", Color(1, 1, 1), 0.1)

func mostrar_nuevo_record():
	if not record_label:
		return
	
	record_label.visible = true
	record_label.text = "¡NUEVO RÉCORD!"
	record_label.modulate = Color(1, 1, 1, 0)
	record_label.scale = Vector2(0.5, 0.5)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	
	# Animación de récord: aparece con gran explosión
	tween.tween_property(record_label, "scale", Vector2(2.0, 2.0), 0.7)
	tween.parallel().tween_property(record_label, "modulate:a", 1.0, 0.5)
	
	tween.tween_property(record_label, "scale", Vector2(1.3, 1.3), 0.4)
	
	# Efecto de partículas doradas (simulado con cambios de color)
	var tween_color = create_tween()
	tween_color.set_loops(3)
	tween_color.tween_property(record_label, "modulate", Color(1, 1, 0.5), 0.2)
	tween_color.tween_property(record_label, "modulate", Color(1, 0.8, 0.3), 0.2)
	
	# Sonido especial para récord
	Efectos.stream = preload("res://sounds/8-bit-powerup-6768.mp3")
	Efectos.volume_db = 0
	Efectos.play()
	
	print("🏆 ¡NUEVO RÉCORD! Animación especial activada")

func mostrar_monedas():
	if not monedas_label:
		return
	
	monedas_label.visible = true
	monedas_label.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	
	# Aparece
	tween.tween_property(monedas_label, "scale", Vector2(1.0, 1.0), 0.6)
	tween.parallel().tween_property(monedas_label, "modulate:a", 1.0, 0.4)
	
	# Contar monedas
	tween.tween_callback(func(): animar_contador_monedas())

func animar_contador_monedas():
	if not monedas_label:
		return
	
	animando_monedas = true
	monedas_actuales = 0
	
	# Crear tween para contar
	var tween = create_tween()
	var duracion = min(2.0, max(0.8, monedas_finales / 30.0))  # Ajustar duración según monedas
	
	tween.tween_method(Callable(self, "actualizar_contador_monedas"), 0, monedas_finales, duracion)
	tween.tween_callback(func(): 
		animando_monedas = false
		# Efecto especial al terminar de contar monedas
		efecto_final_monedas()
	)

func actualizar_contador_monedas(valor: float):
	if not monedas_label:
		return
	
	monedas_actuales = int(valor)
	monedas_label.text = "Monedas: " + str(monedas_actuales)
	
	# Efecto visual más llamativo para monedas
	if int(valor) % 5 == 0:  # Cada 5 monedas
		var mini_tween = create_tween()
		mini_tween.tween_property(monedas_label, "scale", Vector2(1.08, 1.08), 0.12)
		mini_tween.parallel().tween_property(monedas_label, "modulate", Color(1, 0.9, 0), 0.08)
		mini_tween.tween_property(monedas_label, "scale", Vector2(1.0, 1.0), 0.12)
		mini_tween.parallel().tween_property(monedas_label, "modulate", Color(1, 1, 1), 0.08)

func efecto_final_monedas():
	if not monedas_label:
		return
	
	# Efecto brillante al terminar de contar monedas
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(monedas_label, "modulate", Color(1, 1, 0.5), 0.3)
	tween.parallel().tween_property(monedas_label, "scale", Vector2(1.15, 1.15), 0.3)
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(monedas_label, "modulate", Color(1, 1, 1), 0.3)
	tween.parallel().tween_property(monedas_label, "scale", Vector2(1.0, 1.0), 0.3)
	
	# Sonido de monedas
	Efectos.stream = preload("res://sounds/8bit-sound-3-270296.mp3")
	Efectos.volume_db = -5
	Efectos.play()

func mostrar_botones():
	# Mostrar botón Reintentar
	if btn_reintentar:
		btn_reintentar.visible = true
		btn_reintentar.modulate = Color(1, 1, 1, 0)
		btn_reintentar.scale = Vector2(0.3, 0.3)
		
		var tween1 = create_tween()
		tween1.set_trans(Tween.TRANS_BACK)
		tween1.set_ease(Tween.EASE_OUT)
		tween1.tween_property(btn_reintentar, "scale", Vector2(1.0, 1.0), 0.6)
		tween1.parallel().tween_property(btn_reintentar, "modulate:a", 1.0, 0.5)
		
		# Efecto de brillo intermitente
		var tween_brillo1 = create_tween()
		tween_brillo1.set_loops()
		tween_brillo1.tween_property(btn_reintentar, "modulate", Color(0.9, 1, 0.9), 0.8)
		tween_brillo1.tween_property(btn_reintentar, "modulate", Color(1, 1, 1), 0.8)
	
	# Mostrar botón Salir con retraso
	if btn_salir:
		btn_salir.visible = true
		btn_salir.modulate = Color(1, 1, 1, 0)
		btn_salir.scale = Vector2(0.3, 0.3)
		
		var tween2 = create_tween()
		tween2.set_trans(Tween.TRANS_BACK)
		tween2.set_ease(Tween.EASE_OUT)
		tween2.tween_interval(0.3)
		tween2.tween_property(btn_salir, "scale", Vector2(1.0, 1.0), 0.6)
		tween2.parallel().tween_property(btn_salir, "modulate:a", 1.0, 0.5)
		
		# Efecto de brillo intermitente
		var tween_brillo2 = create_tween()
		tween_brillo2.set_loops()
		tween_brillo2.tween_property(btn_salir, "modulate", Color(1, 0.9, 0.9), 0.8)
		tween_brillo2.tween_property(btn_salir, "modulate", Color(1, 1, 1), 0.8)
	
	# Habilitar entrada
	entra = true
	
	print("🎮 Botones habilitados - ¡Juego listo para continuar!")

func _on_btn_reintentar_pressed() -> void:
	# Efecto al presionar más pronunciado
	if btn_reintentar:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(btn_reintentar, "scale", Vector2(0.8, 0.8), 0.15)
		tween.parallel().tween_property(btn_reintentar, "modulate", Color(0.7, 1, 0.7), 0.1)
		tween.tween_property(btn_reintentar, "scale", Vector2(1.0, 1.0), 0.15)
		tween.parallel().tween_property(btn_reintentar, "modulate", Color(1, 1, 1), 0.1)
	
	# Sonido de confirmación
	Efectos.stream = preload("res://sounds/8-bit-powerup-6768.mp3")
	Efectos.volume_db = -5
	Efectos.play()
	
	# Pequeña pausa antes de cambiar de escena
	await get_tree().create_timer(0.2).timeout
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/juego_2.tscn")
	Efectos.stop()

func _on_btn_salir_pressed() -> void:
	# Efecto al presionar más pronunciado
	if btn_salir:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(btn_salir, "scale", Vector2(0.8, 0.8), 0.15)
		tween.parallel().tween_property(btn_salir, "modulate", Color(1, 0.7, 0.7), 0.1)
		tween.tween_property(btn_salir, "scale", Vector2(1.0, 1.0), 0.15)
		tween.parallel().tween_property(btn_salir, "modulate", Color(1, 1, 1), 0.1)
	
	# Sonido de confirmación
	Efectos.stream = preload("res://sounds/8-bit-powerup-6768.mp3")
	Efectos.volume_db = -5
	Efectos.play()
	
	# Pequeña pausa antes de cambiar de escena
	await get_tree().create_timer(0.2).timeout
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/seleccion_videojuego.tscn")
	GlobalAudio.stream = preload("res://sounds/level-7-27947.mp3")
	GlobalAudio.stream.loop = true
	GlobalAudio.play()
	Efectos.stop()

func _input(event):
	if entra:
		if event.is_action_pressed("ui_cancel"): 
			_on_btn_salir_pressed()
		if event.is_action_pressed("Reiniciar"):
			_on_btn_reintentar_pressed()

func _on_visibility_changed() -> void:
	entra = true
	
	# Si la pantalla se hace visible, iniciar animaciones automáticamente
	if visible:
		cargar_datos_juego()
