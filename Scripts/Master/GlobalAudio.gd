extends AudioStreamPlayer

func _ready():
	# Espera un frame para asegurar que Global ya se cargó
	call_deferred("_setup_audio")

func _setup_audio():
	bus = "Master"
	autoplay = true
	
	# Aplica el volumen de música (75%)
	var music_volume_db = lerp(-40.0, 0.0, Global.music_volume)
	volume_db = music_volume_db
	
	print("GlobalAudio - Volumen aplicado: ", Global.music_volume * 100, "%")
	
	if not playing:
		stream = preload("res://sounds/level-7-27947.mp3")
		stream.loop = true
		play()
