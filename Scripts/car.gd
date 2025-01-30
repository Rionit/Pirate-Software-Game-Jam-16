extends Node3D
class_name Car

signal car_destroyed

@onready var car_body: RigidBody3D = $CarBody

var colliders: Array
var parts_pinched : int = 0

func _ready() -> void:
	for col in colliders:
		car_body.add_child(col)
	car_body.contact_monitor = true
	car_body.max_contacts_reported = 1
	car_body.body_entered.connect(hit)

func hit(body: Node):
	Audio.play(Audio.spawn(self, Audio.get_random_sound(Audio.hit_sounds), "Outside"))

func collider_duplicated(collider: CollisionShape3D):
	colliders.append(collider)

func car_part_pinched():
	parts_pinched += 1
	if colliders.size() == parts_pinched:
		car_destroyed.emit()
		queue_free()
