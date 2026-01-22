extends Node

# Variables globales para el volumen
var global_volume: float = 0.75      # 100%
var music_volume: float = 0.50      # 75% - ¡ESTE ES EL VALOR QUE QUIERES!
var effects_volume: float = 0.50     # 100%

func _ready():
	# Aplica el volumen inmediatamente cuando el juego inicia
	call_deferred("_apply_initial_audio_settings")

func _apply_initial_audio_settings():
	# Aplica el volumen general (Master bus)
	var master_volume_db = lerp(-40.0, 0.0, global_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume_db)
	
	print("=== AUDIO INICIALIZADO ===")
	print("Volumen Master: ", global_volume * 100, "%")
	print("Volumen Música: ", music_volume * 100, "%")  # Debería mostrar 75%
	print("Volumen Efectos: ", effects_volume * 100, "%")
