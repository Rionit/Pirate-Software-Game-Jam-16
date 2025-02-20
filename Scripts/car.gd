extends RigidBody3D
class_name Car

signal car_destroyed

var colliders: Array
var parts_pinched : int = 0

func _ready() -> void:
	for col in colliders:
		add_child(col)
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(hit)

func hit(_body: Node):
	Audio.play(Audio.spawn(self, Audio.get_random_sound(Audio.hit_sounds), "Outside"))

func collider_duplicated(collider: CollisionShape3D):
	colliders.append(collider)

func car_part_pinched():
	parts_pinched += 1
	if colliders.size() == parts_pinched:
		car_destroyed.emit()
		queue_free()
