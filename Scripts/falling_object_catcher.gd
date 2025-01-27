extends Area3D

@onready var object_spawn: Marker3D = %ObjectSpawn

func _on_body_entered(body: Node3D) -> void:
	body.global_position = object_spawn.global_position
