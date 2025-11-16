extends AudioStreamPlayer

func _ready():
	# Configura el audio para que no se detenga al cambiar de escena
	bus = "Master"  # Asegúrate de que esté en el bus correcto
	autoplay = true  # Si quieres que comience a reproducirse automáticamente
	if not playing:
		stream = preload("res://sounds/level-7-27947.mp3")
		stream.loop = true
		play()
