extends Node


var vidas = 3
@onready var coco = $coco
@onready var barril = $barril
var VELOCIDAD_BARRIL = 200
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
@onready var puntostxt = $Puntos
var puntos = 0
var carga=0
var max_barril = 5
var espera = 3.2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	textoVidas.text = "Vidas: " + str(vida) 
	crear_barril()
	var pantalla_ancho = get_viewport().size.x
	GlobalAudio.stream = preload("res://sounds/very-lush-and-swag-loop-74140.mp3")
	GlobalAudio.stream.loop = true
	GlobalAudio.play()
	$Jugador/muerto.area_entered.connect(detecta)





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	puntos = puntos+1
	
	tiempo_actual += delta
	
	puntostxt.text = "SCORE: "+str(puntos)
	
	if carga == 500:
		max_cocos=max_cocos+1
	
	if carga == 1000:
		carga=0
		max_cocos=max_cocos+1
		max_barril =max_barril+1
	else:
		carga=carga+1
	
	if cocos_en_pantalla < max_cocos and tiempo_actual >= tiempo_entre_cocos:
		crear_coco()
		tiempo_actual = 0  # Reiniciar temporizador
		tiempo_entre_cocos = tiempo_entre_cocos-0.05
	
	
	for barril in get_children():
		if barril==null:
			pass
		else:
			if barril.has_meta("direccion"):
				barril.position.x += barril.get_meta("direccion") * VELOCIDAD_BARRIL * delta
				
				# Eliminar barriles que salgan de la pantalla
				if barril.position.x < -100 or barril.position.x > get_viewport().size.x + 100:
					barril.queue_free()
					veces = veces-1
					print(veces)
					while veces < max_barril:
						crear_barril()
						await get_tree().create_timer(espera).timeout



func crear_barril():
	veces += 1
	var nBarril = barril.duplicate()
	add_child(nBarril)
	
	var pantalla_ancho = get_viewport().size.x
	var lado = randi_range(1, 2) #Numero aleatorio entre 1 y 2
	
	
	
	if lado == 1:
		nBarril.position = Vector2(30, 550)
		nBarril.set_meta("direccion", 1)
		espera = espera+0.5
	else:
		nBarril.position = Vector2(pantalla_ancho-30, 550)
		nBarril.set_meta("direccion", -1)
		espera = espera-0.5
	
	
	
	




func crear_coco():
	if cocos_en_pantalla >= max_cocos:
		return  # No crear más cocos si ya hay el máximo permitido
	
	var nCoco = coco.duplicate()
	add_child(nCoco)
	cocos_en_pantalla += 1
	
	var pantalla_ancho = get_viewport().size.x
	var posicioAleatoria = randi_range(50, pantalla_ancho - 50)
	
	nCoco.position = Vector2(posicioAleatoria, -50)
	
	var tween = get_tree().create_tween()
	tween.tween_property(nCoco, "position", Vector2(posicioAleatoria, get_viewport().size.y + 50), 2.5)
	
	# Cuando el coco toca el suelo, lo eliminamos y reducimos el contador
	nCoco.body_entered.connect(func(body):
		if body.name == "suelo":
			nCoco.queue_free()
			cocos_en_pantalla -= 1  # Reducimos el contador
		if body.name == "Jugador":
			nCoco.queue_free()
			cocos_en_pantalla -= 1
	)
	




func detecta(body):
	
	
	if vida ==1:
		vida=vida-1
		textoVidas.text = "Vidas: " + str(vida)
		
		$pantallaMuerte.visible = not $pantallaMuerte.visible
		
	else:
		Efectos.stream = preload("res://sounds/daño.mp3")
		Efectos.play()
		vida=vida-1
		textoVidas.text = "Vidas: " + str(vida)


func _on_pantalla_muerte_visibility_changed() -> void:
	get_tree().paused = not get_tree().paused
	Efectos.stream = preload("res://sounds/game-over.mp3")
	Efectos.play()
