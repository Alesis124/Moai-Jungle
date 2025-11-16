extends Control

@onready var music = GlobalAudio
@onready var efect = Efectos
@onready var porcentaje = $ColorRect/porcentaje
@onready var porcentaje2 = $ColorRect/porcentaje2
@onready var porcentaje3 = $ColorRect/porcentaje3
@onready var barraGeneral = $ColorRect/VolumenGeneral
@onready var barraMusica = $ColorRect/VolumenMusica
@onready var barraEfectos = $ColorRect/VolumenEfectos
@onready var brillo = $ColorRect

var global_volume: float = 1.0
var music_volume: float = 1.0
var effects_volume: float = 1.0
var espera: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	barraGeneral.value = Global.global_volume * 100
	barraMusica.value = Global.music_volume * 100
	barraEfectos.value = Global.effects_volume * 100
	espera = true
	
	
	porcentaje.text = str(int(barraGeneral.value))+" %"
	porcentaje2.text = str(int(barraMusica.value))+" %"
	porcentaje3.text = str(int(barraEfectos.value))+" %"
	
	brillo.modulate.a = GlobalBrightnes.brillo
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_volumen_general_value_changed(value: float) -> void:
	Global.global_volume = value / 100.0
	if value <=0:
		music.stop()
		porcentaje.text = "0%"
	else:
		if not GlobalAudio.playing:
			music.play()
		var volume_db = lerp(-40.0, 0.0, value/100)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)
		porcentaje.text = str(int(value))+" %"
		if not espera:
			pass
		else:
			efect.stream = preload("res://sounds/8bit-sound-3-270296.mp3")
			efect.play()
	
		


func _on_volumen_musica_value_changed(value: float) -> void:
	Global.music_volume = value / 100.0
	if value <=0:
		music.stop()
		porcentaje2.text = "0%"
	else:
		if not GlobalAudio.playing:
			music.play()
		var volume_db = lerp(-40.0, 0.0, value/100)
		music.volume_db = volume_db
		porcentaje2.text = str(int(value))+" %"




func _on_volumen_efectos_value_changed(value: float) -> void:
	Global.effects_volume = value / 100.0
	if value <=0:
		music.stop()
		porcentaje2.text = "0%"
	else:
		var volume_db = lerp(-40.0, 0.0, value/100)
		efect.volume_db = volume_db
		if not espera:
			pass
		else:
			efect.stream = preload("res://sounds/8bit-sound-3-270296.mp3")
			efect.play()
		porcentaje3.text = str(int(value))+" %"



func _on_btn_aceptar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/options.tscn")
