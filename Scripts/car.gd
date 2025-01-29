extends Node3D
class_name Car

signal car_destroyed

@onready var car_body: Node3D = $CarBody

var colliders: Array
var parts_pinched : int = 0

func _ready() -> void:
	for col in colliders:
		car_body.add_child(col)

func collider_duplicated(collider: CollisionShape3D):
	colliders.append(collider)

func car_part_pinched():
	parts_pinched += 1
	if colliders.size() == parts_pinched:
		car_destroyed.emit()
		queue_free()
