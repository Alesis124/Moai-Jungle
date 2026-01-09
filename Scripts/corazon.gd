extends Area2D

signal recogido  # Señal que se emite cuando el jugador recoge el objeto

var velocidad_caida := 150.0  # Velocidad de caída

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	position.y += velocidad_caida * delta

func _on_body_entered(body):
	if body.name == "Jugador":
		emit_signal("recogido")
		queue_free()
	elif body.name == "suelo":
		queue_free()
