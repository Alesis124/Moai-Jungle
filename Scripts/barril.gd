extends Area2D

signal choco_con_pared
signal barril_roto

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var esta_roto := false
var hace_dano := true
var direccion := 1
var velocidad := 200


func _ready():
	# Conectar señal de colisión
	connect("body_entered", Callable(self, "_on_body_entered"))

	# Animación inicial
	if animated_sprite.sprite_frames.has_animation("movimiento"):
		animated_sprite.play("movimiento")


func _process(delta):
	if esta_roto:
		return

	# Movimiento del barril
	position.x += direccion * velocidad * delta

	# Rotación visual (opcional)
	animated_sprite.rotation += direccion * velocidad * delta * 0.0008


func _on_body_entered(body):
	if body.name == "Jugador" and not esta_roto and hace_dano:
		emit_signal("barril_roto", self)

func romper():
	print("ROMPIENDO BARRIL REAL:", self)
	
	esta_roto = true
	hace_dano = false
	collision_shape.set_deferred("disabled", true)
	
	# DETENER movimiento y rotación
	set_process(false)
	
	# RESETEAR rotación primero
	animated_sprite.rotation = 0
	
	# Usar flip_h en lugar de rotar 180 grados
	# Si viene de la derecha, voltear horizontalmente
	if direccion == -1:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false
	
	# Conectar para detectar cuando cambia de frame
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
	# Reproducir animación de romperse
	animated_sprite.play("romperse")
	
	# Usar un timer en lugar de await
	var timer = get_tree().create_timer(0.8)  # 0.8 segundos para la animación
	await timer.timeout
	
	print("BORRANDO BARRIL:", self)
	queue_free()

func _on_frame_changed():
	# Cuando llegue al frame 3, bajar la posición
	if animated_sprite.frame >= 4:
		# Mover hacia abajo (aumentar Y)
		position.y += 16.5  # Ajusta este valor según necesites
		
		# Desconectar para que no se siga ejecutando
		animated_sprite.frame_changed.disconnect(_on_frame_changed)
