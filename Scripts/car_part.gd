extends RigidBody3D
class_name CarPart

const JUNK_PARTICLES = preload("res://Scenes/junk_particles.tscn")

signal collider_duplicated(_collider: CollisionShape3D)

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var car: Car = $"../.."

@export var mesh: MeshInstance3D

var duplicated_collider: CollisionShape3D
var blend_shape_idx: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if mesh == null:
		print("No MeshInstance3D found as a child!")
	blend_shape_idx = mesh.find_blend_shape_by_name("Damage")
	name = mesh.name
	collider.name = name + "_Collider"
	
	collider_duplicated.connect(car.collider_duplicated)
	duplicated_collider = collider.duplicate()
	collider_duplicated.emit(duplicated_collider)
	
	freeze = true
	collision_layer = 0b10
	collision_mask = 0b10
	
func pinch(tip: Node3D):
	if duplicated_collider != null:
		duplicated_collider.queue_free()

	self.reparent(tip)
	self.freeze = true
	JUNK_PARTICLES.instantiate().init_on_point(get_tree().root, tip)
	damage(1.0)
	return self

func release(angular_velocity: float, velocity: Vector3):
	self.reparent(get_tree().get_root())
	self.freeze = false
	self.angular_velocity.y = -angular_velocity
	self.linear_velocity = velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage(amount: float) -> void:
	mesh.set_blend_shape_value(blend_shape_idx, clamp(amount, -1, 1))
