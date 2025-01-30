extends AudioStreamPlayer3D
class_name OneShotPlayer

func _on_finished() -> void:
	queue_free()
