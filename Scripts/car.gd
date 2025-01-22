extends Node3D
class_name Car

@onready var car_body: Node3D = $CarBody

var colliders: Array

func _ready() -> void:
	for col in colliders:
		car_body.add_child(col)

func collider_duplicated(collider: CollisionShape3D):
	colliders.append(collider)
