extends Area2D
signal choco_con_pared

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Pared"):
		emit_signal("choco_con_pared", self)
