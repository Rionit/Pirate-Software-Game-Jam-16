extends StaticBody3D
class_name TrashPile

enum TrashTypes {METAL, GLASS, INTERIOR, ENGINE, BATTERY, AXLE}

@export var area: Area3D
@export var trash_type: TrashTypes

func _ready() -> void:
	area.connect("body_entered", trash_entered)

func trash_entered(trash: Node3D):
	if trash is CarPart:
		trash.queue_free()
