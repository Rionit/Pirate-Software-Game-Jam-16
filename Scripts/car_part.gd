extends RigidBody3D
class_name CarPart

## CarPart
##
## Represents a detachable part of a car, extending [RigidBody3D].
## Handles collision, highlighting, pinching mechanics, and damage simulation.
## When separated from the car, it can be interacted with independently.


## Preloaded particle effect for junk debris when the part is detached.
const JUNK_PARTICLES = preload("res://Scenes/junk_particles.tscn")
## Preloaded outline [Shader] used for highlighting the part.
const OUTLINE = preload("res://Shaders/outline.gdshader")
## Preloaded shine [Shader] used for visual effects.
const SHINE = preload("res://Shaders/shine.gdshader")
## Preloaded PSX [Shader] for retro-style rendering.
const PSX = preload("res://Shaders/psx.gdshader")

## Emitted when the collider is duplicated.
signal collider_duplicated(_collider: CollisionShape3D)
## Emitted when the part is pinched (grabbed by an external object).
signal pinched

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var car: Car = $".."  ## Reference to the parent [Car] object.

## The [MeshInstance3D] of the car part.
@export var mesh: MeshInstance3D
## The type of trash this part represents, categorized in [constant Global.TrashTypes].
@export var type: Global.TrashTypes

## Shader material used for applying special effects like highlighting.
var shader_material := ShaderMaterial.new()
## A duplicate of the collision shape, used when detaching.
var duplicated_collider: CollisionShape3D
## The index of the "Damage" blend shape for visual deformation.
var blend_shape_idx: int
## Stores the last parent before detachment, to allow reattachment.
var last_parent: Node3D
## Tracks whether the [CarPart] has been separated from the car.
var is_separated := false

func _ready() -> void:
	if mesh == null:
		print("No MeshInstance3D found as a child!")
	blend_shape_idx = mesh.find_blend_shape_by_name("Damage")
	
	# Setup material parameters
	var material: ShaderMaterial = mesh.get_active_material(0)
	if material != null:
		material.set_shader_parameter("shine_width", 50.0)
		material.set_shader_parameter("shine_color", Color.AQUA)
	
	# Setup outline shader for highlighting
	shader_material.shader = OUTLINE
	shader_material.set_shader_parameter("outline_width", 2.0)
	shader_material.set_shader_parameter("outline_color", Color.AQUA)
	shader_material.resource_local_to_scene = true
	
	# Rename collider for better organization
	collider.name = name + "_Collider"
	
	# Connect signals for interaction with the car
	pinched.connect(car.car_part_pinched)
	collider_duplicated.connect(car.collider_duplicated)
	duplicated_collider = collider.duplicate()
	collider_duplicated.emit(duplicated_collider)
	
	# Configure collision settings
	freeze = true
	collision_layer = 0b10
	collision_mask = 0b10
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(hit)

## Called when the part collides with another object. It plays a random hit sound.
func hit(_body: Node):
	Audio.play(Audio.spawn(self, Audio.get_random_sound(Audio.hit_sounds), "Outside"))

## Highlights the car part using an outline [Shader].
## If [param state] is true, enables highlight; otherwise, disables it.
func highlight(state := true):
	var material: ShaderMaterial = mesh.get_active_material(0)
	if material == null:
		return
	if state:
		material.next_pass = shader_material
		material.set_shader_parameter("is_shining", true)
	else:
		material.next_pass = null
		material.set_shader_parameter("is_shining", false)

## Handles the pinching (grabbing) of the [CarPart] by an external object.
## If the [CarPart] is the main car body, the entire car is affected.
## [param tip] is the object that is pinching this [CarPart].
func pinch(tip: Node3D):
	print(name)
	
	if car != null and name == "Body" and car.parts_pinched < car.colliders.size() - 1:
		last_parent = car.get_parent_node_3d()
		car.reparent(tip)
		car.freeze = true
		damage(0.2)
	else:
		if duplicated_collider != null:
			duplicated_collider.queue_free()
		self.reparent(tip)
		self.freeze = true
		if not is_separated:
			pinched.emit()
		damage(0.5)
		is_separated = true
	
	JUNK_PARTICLES.instantiate().init_on_point(get_tree().root, tip)
	return self

## Releases the [CarPart], applying velocity and reattaching if necessary.
## [param angular_velocity] is the rotational speed at which the part is released.
## [param velocity] is the linear velocity of the part upon release.
func release(angular_velocity: float, velocity: Vector3):
	if car != null and name == "Body" and car.parts_pinched <= car.colliders.size() - 1:
		car.reparent(last_parent)
		car.freeze = false
		car.angular_velocity.y = -angular_velocity
		car.linear_velocity = velocity
	else:
		self.reparent(Global.level_root)
		self.freeze = false
		self.angular_velocity.y = -angular_velocity
		self.linear_velocity = velocity

## Applies damage to the car part by increasing the blend shape value.
## [param amount] is the amount of damage to apply, clamped between -1 and 1.
## Negative values bend the other way. Useful for visual randomness.
func damage(amount: float) -> void:
	if blend_shape_idx == -1:
		return
	var current = mesh.get_blend_shape_value(blend_shape_idx)
	mesh.set_blend_shape_value(blend_shape_idx, clamp(current + amount, -1, 1))
