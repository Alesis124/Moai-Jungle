extends Area2D

var velocidad_caida := 200.0  # Puedes ajustar esta velocidad según lo que necesites


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))  # Esto conecta la señal


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += velocidad_caida * delta
	if position.y > get_viewport().get_visible_rect().size.y + 50:
		queue_free()



func _on_body_entered(body):
	if body.name == "Jugador" or body.name == "suelo":
		queue_free()
