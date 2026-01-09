extends Node


var vidas = 3
@onready var coco = $coco
@onready var barril = $barril
@onready var corazon = $Corazon
@onready var escudo = $Escudo
@onready var duracion = $Duracion
@onready var ala = $Ala
@onready var zapatilla = $Zapa
var timer_escudo
var puntos_tiempo := 0.0
var barriles_en_pantalla = 0
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
var tiempo_barril = 0.0
@onready var textoVidas = $vidas
@onready var puntostxt = $Puntos
var puntos = 0
var carga=0
var pantalla_ancho
var max_barril = 4
var espera = 3.2
var screen_size := Vector2.ZERO
var ancho_entre_paredes




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	
	pantalla_ancho = get_viewport().size.x
	GlobalAudio.stream = preload("res://sounds/very-lush-and-swag-loop-74140.mp3")
	GlobalAudio.stream.loop = true
	GlobalAudio.play()
	textoVidas.text = "Vidas: " + str(vida) 
	duracion.visible = false
	crear_barril()

	# Timers separados para cada poder
	timer_escudo = Timer.new()
	timer_ala = Timer.new()
	timer_zapa = Timer.new()

	timer_escudo.one_shot = true
	timer_ala.one_shot = true
	timer_zapa.one_shot = true

	timer_escudo.wait_time = 5.0
	timer_ala.wait_time = 5.0
	timer_zapa.wait_time = 5.0

	timer_escudo.timeout.connect(_fin_escudo)
	timer_ala.timeout.connect(_fin_ala)
	timer_zapa.timeout.connect(_fin_zapatilla)

	add_child(timer_escudo)
	add_child(timer_ala)
	add_child(timer_zapa)

	$Jugador/muerto.area_entered.connect(detecta)
	ancho_entre_paredes = pared_derecha.position.x - pared_izquierda.position.x

	







# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	puntos_tiempo += delta
	if puntos_tiempo >= 1.0:
		puntos += 1
		puntos_tiempo = 0.0
		
		if puntos % 15 == 0:
			creamos_objeto()

		# Aumentar dificultad cada 100 puntos
		if puntos % 20 == 0:
			max_cocos += 1
			max_barril += 1
			VELOCIDAD_BARRIL += 20
			tiempo_entre_cocos = max(0.1, tiempo_entre_cocos - 0.02)
			print("¡Dificultad aumentada! Nivel de puntos: ", puntos)

	tiempo_actual += delta

	if duracion.visible and (invulnerable or doble_salto or velocidad_extra):
		duracion.value -= delta

	puntostxt.text = "SCORE: " + str(puntos)

	if cocos_en_pantalla < max_cocos and tiempo_actual >= tiempo_entre_cocos:
		crear_coco()
		tiempo_actual = 0
		tiempo_entre_cocos = max(0.1, tiempo_entre_cocos - 0.005)

	for barril in get_children():
		if barril != null and barril.has_meta("direccion"):
			barril.position.x += barril.get_meta("direccion") * VELOCIDAD_BARRIL * delta
			tiempo_barril += delta
			if tiempo_barril >= espera and barriles_en_pantalla < max_barril:
				crear_barril()
				tiempo_barril = 0.0


func _on_viewport_resized():
	pantalla_ancho = get_viewport().size.x
	print("Tamaño de pantalla actualizado: ", pantalla_ancho)


func crear_barril():
	
	var nBarril = barril.duplicate()
	add_child(nBarril)

	var pantalla_ancho = get_viewport().get_visible_rect().size.x
	var lado = randi_range(1, 2)

	if lado == 1:
		nBarril.position = Vector2(30, 550)
		nBarril.set_meta("direccion", 1)
	else:
		nBarril.position = Vector2(pantalla_ancho - 30, 550)
		nBarril.set_meta("direccion", -1)

	nBarril.connect("choca_con_pared", Callable(self, "_on_barril_choca_con_pared").bind(nBarril))

	barriles_en_pantalla += 1



func _on_barril_choco_con_pared(barril):
	barriles_en_pantalla -= 1
	barril.queue_free()
	
	# Intenta crear otro si aún puedes
	if barriles_en_pantalla < max_barril:
		crear_barril()


func _on_barril_choca(body):
	if body == pared_derecha:
		var barril = body.get_parent()
		barril.queue_free()




func _input(event):
	if event.is_action_pressed("Reiniciar"):
		get_tree().change_scene_to_file("res://Scenes/juego_2.tscn")



func crear_coco():
	if cocos_en_pantalla >= max_cocos:
		return

	var margen = 20  # Ajusta a tu gusto
	var posicioAleatoria := randi_range(
		pared_izquierda.global_position.x + margen,
		pared_derecha.global_position.x - margen
	)


	var escena_coco = preload("res://sprites/coco.tscn")
	var nCoco = escena_coco.instantiate()
	add_child(nCoco)
	cocos_en_pantalla += 1
	

	nCoco.position = Vector2(posicioAleatoria, -50)

	nCoco.tree_exited.connect(func():
		cocos_en_pantalla -= 1
	)



func creamos_objeto():
	var objeto = randi_range(1, 4)
	
	var margen = 20  # Ajusta a tu gusto
	var posicioAleatoria := randi_range(
		pared_izquierda.global_position.x + margen,
		pared_derecha.global_position.x - margen
	)

	if objeto == 1:
		var corazon_escena = preload("res://sprites/corazon.tscn")
		nCorazon = corazon_escena.instantiate()
		add_child(nCorazon)
		nCorazon.position = Vector2(posicioAleatoria, -50)

		# Conectar la señal
		nCorazon.connect("recogido", Callable(self, "_on_corazon_recogido"))
	if objeto== 2:
		var escudo_escena = preload("res://sprites/escudo.tscn")
		nEscudo = escudo_escena.instantiate()
		add_child(nEscudo)
		nEscudo.position = Vector2(posicioAleatoria, -50)
		nEscudo.connect("recogido", Callable(self, "_on_escudo_recogido"))
	if objeto == 3:
		var ala_escena = preload("res://sprites/ala.tscn")
		nAla = ala_escena.instantiate()
		add_child(nAla)
		nAla.position = Vector2(posicioAleatoria, -50)
		nAla.connect("recogido", Callable(self, "_on_ala_recogida"))

	elif objeto == 4:
		var zapa_escena = preload("res://sprites/zapa.tscn")
		nZapa = zapa_escena.instantiate()
		add_child(nZapa)
		nZapa.position = Vector2(posicioAleatoria, -50)
		nZapa.connect("recogido", Callable(self, "_on_zapatilla_recogida"))



func _on_corazon_recogido():
	vida += 1
	textoVidas.text = "Vidas: " + str(vida)






func _on_invulnerabilidad_terminada():
	invulnerable = false
	duracion.visible = false


func _on_escudo_recogido():
	invulnerable = true
	duracion.max_value = 5.0
	duracion.value = 5.0
	duracion.visible = true
	timer_escudo.start()


func _on_ala_recogida():
	doble_salto = true
	duracion.max_value = 5.0
	duracion.value = 5.0
	duracion.visible = true
	timer_ala.start()

func _on_zapatilla_recogida():
	velocidad_extra = true
	duracion.max_value = 5.0
	duracion.value = 5.0
	duracion.visible = true
	timer_zapa.start()


func _fin_escudo():
	invulnerable = false
	duracion.visible = false

func _fin_ala():
	doble_salto = false
	duracion.visible = false

func _fin_zapatilla():
	velocidad_extra = false
	duracion.visible = false


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


func detecta(body):
	if body == nCorazon or body == nEscudo or body ==nAla or body ==nZapa:
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



func _on_pantalla_muerte_visibility_changed() -> void:
	get_tree().paused = not get_tree().paused
	GlobalAudio.stream = preload("res://sounds/game-over.mp3")
	GlobalAudio.play()
