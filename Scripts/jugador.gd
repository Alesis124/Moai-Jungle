extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const FAST_FALL_MULT = 4

var doble_salto := false
var velocidad_extra := false
var salto_extra_disponible := false

func _physics_process(delta: float) -> void:
	var padre = get_parent()
	var salto_habilitado = padre.doble_salto
	var velocidad_rapida = padre.velocidad_extra

	# Activar gravedad
	if not is_on_floor():
		var gravedad = get_gravity()

		if Input.is_action_pressed("bajar"):
			# Si aún está subiendo, cortamos el salto
			if velocity.y < 0:
				velocity.y = 0

			# Aceleramos la caída
			gravedad *= FAST_FALL_MULT

		velocity += gravedad * delta



	else:
		salto_extra_disponible = true

	# Saltar o doble salto
	if Input.is_action_just_pressed("salto"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif salto_habilitado and salto_extra_disponible:
			velocity.y = JUMP_VELOCITY
			salto_extra_disponible = false
	# Movimiento horizontal
	var direction := Input.get_axis("izquierda", "derecha")
	if direction:
		var speed_actual = SPEED
		if velocidad_rapida:
			speed_actual *= 2
		velocity.x = direction * speed_actual
		$Movimiento_jugador.flip_h = direction < 0
		$Movimiento_jugador.play("caminar")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$Movimiento_jugador.play("estatico")

	move_and_slide()
