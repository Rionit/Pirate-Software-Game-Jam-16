extends RigidBody3D
class_name CarPart

signal collider_duplicated(_collider: CollisionShape3D)

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var car: Car = $"../.."

@export var duplicated_collider: CollisionShape3D
@export var mesh: MeshInstance3D

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage(amount: float) -> void:
	mesh.set_blend_shape_value(blend_shape_idx, clamp(amount, -1, 1))
