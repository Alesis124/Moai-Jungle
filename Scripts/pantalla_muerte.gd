extends CanvasLayer

var entra =false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entra=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_btn_reintentar_pressed() -> void:
	get_tree().paused = not get_tree().paused
	get_tree().change_scene_to_file("res://Scenes/juego_2.tscn")
	Efectos.stop()
	
	


func _on_btn_salir_pressed() -> void:
	get_tree().paused = not get_tree().paused
	get_tree().change_scene_to_file("res://Scenes/seleccion_videojuego.tscn")
	GlobalAudio.stream = preload("res://sounds/level-7-27947.mp3")
	GlobalAudio.stream.loop = true
	GlobalAudio.play()
	Efectos.stop()
	


func _input(event): #Detecta el teclado
	if entra:
		
		if event.is_action_pressed("ui_cancel"): 
			get_tree().paused = not get_tree().paused
			get_tree().change_scene_to_file("res://Scenes/seleccion_videojuego.tscn")
			GlobalAudio.stream = preload("res://sounds/level-7-27947.mp3")
			GlobalAudio.stream.loop = true
			GlobalAudio.play()
			Efectos.stop()


func _on_visibility_changed() -> void:
	entra=true
