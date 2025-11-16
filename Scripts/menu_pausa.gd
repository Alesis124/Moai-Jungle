extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _input(event): #Detecta el teclado
	if event.is_action_pressed("ui_cancel"): 
		get_tree().paused = not get_tree().paused
		$fondo.visible = not $fondo.visible
		$btnReanudar.visible = not $btnReanudar.visible
		$btnReiniciar.visible = not $btnReiniciar.visible
		$btnSalir.visible = not $btnSalir.visible





func _on_btn_reanudar_pressed() -> void:
	get_tree().paused = not get_tree().paused
	$fondo.visible = not $fondo.visible
	$btnReanudar.visible = not $btnReanudar.visible
	$btnReiniciar.visible = not $btnReiniciar.visible
	$btnSalir.visible = not $btnSalir.visible







func _on_btn_reiniciar_pressed() -> void:
	get_tree().paused = not get_tree().paused
	get_tree().change_scene_to_file("res://Scenes/juego_2.tscn")
	





func _on_btn_salir_pressed() -> void:
	get_tree().paused = not get_tree().paused
	get_tree().change_scene_to_file("res://Scenes/seleccion_videojuego.tscn")
	GlobalAudio.stream = preload("res://sounds/level-7-27947.mp3")
	GlobalAudio.stream.loop = true
	GlobalAudio.play()
