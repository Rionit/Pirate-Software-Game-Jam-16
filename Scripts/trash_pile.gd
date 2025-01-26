extends StaticBody3D
class_name TrashPile

const JUNK_PARTICLES = preload("res://Scenes/junk_particles.tscn")

enum TrashTypes {METAL, GLASS, INTERIOR, ENGINE, BATTERY, AXLE}

@export var area: Area3D
@export var trash_type: TrashTypes

func _ready() -> void:
	area.connect("body_entered", trash_entered)

func trash_entered(trash: Node3D):
	if trash is CarPart:
		JUNK_PARTICLES.instantiate().init_on_mesh(get_tree().root, trash.mesh)
		trash.queue_free()
