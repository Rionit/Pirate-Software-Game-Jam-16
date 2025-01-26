extends StaticBody3D
class_name TrashPile

const JUNK_PARTICLES = preload("res://Scenes/junk_particles.tscn")

enum TrashTypes {METAL, GLASS, INTERIOR, ENGINE, BATTERY, AXLE}

@export var area: Area3D
@export var trash_type: TrashTypes
@export var particle_spawn: Node3D

func _ready() -> void:
	area.connect("body_entered", trash_entered)

func trash_entered(trash: Node3D):
	if trash is CarPart:
		var instance = JUNK_PARTICLES.instantiate()
		get_tree().root.add_child(instance)
		var height = trash.mesh.get_aabb().size.y / 2
		instance.global_position = trash.mesh.global_position + Vector3(0, height, 0)
		instance.restart()
		trash.queue_free()
