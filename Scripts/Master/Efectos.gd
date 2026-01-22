extends AudioStreamPlayer

func _ready():
	call_deferred("_setup_effects")

func _setup_effects():
	bus = "Efectos"
	
	# Aplica el volumen de efectos
	var effects_volume_db = lerp(-40.0, 0.0, Global.effects_volume)
	volume_db = effects_volume_db
	
	print("Efectos - Volumen aplicado: ", Global.effects_volume * 100, "%")
