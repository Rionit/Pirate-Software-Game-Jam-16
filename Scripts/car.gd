extends RigidBody3D
class_name Car

## This class handles everything involving the vehicle as a whole.

## Emitted when there is no car part attached to the body of the vehicle.
signal car_destroyed

## These make together the collider of the attached car parts. Each deleted when pinched.
var colliders: Array
## How many car parts have been pinched and ripped apart.
var parts_pinched : int = 0

func _ready() -> void:
	for col in colliders:
		add_child(col)

	# This is needed so that we can play sounds on collisions
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(hit)

## Plays a random hit sound when colliding with another [param _body]
func hit(_body: Node):
	Audio.play(Audio.spawn(self, Audio.get_random_sound(Audio.hit_sounds), "Outside"))

## Appends a duplicated collider of a [CarPart]
func collider_duplicated(collider: CollisionShape3D):
	colliders.append(collider)

## Increments counter of [param parts_pinched] and checks if [Car] is destroyed
func car_part_pinched():
	parts_pinched += 1
	if colliders.size() == parts_pinched:
		car_destroyed.emit()
		queue_free()
