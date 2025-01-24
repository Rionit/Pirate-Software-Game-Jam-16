extends StaticBody3D
class_name TrashPile

enum TrashTypes {METAL, GLASS, INTERIOR, MOTOR, BATTERY}

@export var area: Area3D
@export var trash_type: TrashTypes

func _ready() -> void:
	self.set_collision_layer_value(2, true)
	self.set_collision_layer_value(1, false)
	area.set_collision_layer_value(2, true)
	area.set_collision_layer_value(1, false)
	area.connect("body_entered", trash_entered)

func trash_entered(trash: Node3D):
	if trash is CarPart:
		trash.queue_free()
