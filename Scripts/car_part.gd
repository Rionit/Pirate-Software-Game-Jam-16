extends RigidBody3D
class_name CarPart

const JUNK_PARTICLES = preload("res://Scenes/junk_particles.tscn")
const OUTLINE = preload("res://Shaders/outline.gdshader")
const SHINE = preload("res://Shaders/shine.gdshader")
const PSX = preload("res://Shaders/psx.gdshader")

signal collider_duplicated(_collider: CollisionShape3D)
signal pinched

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var car: Car = $"../.."

@export var mesh: MeshInstance3D
@export var type: Global.TrashTypes

var shader_material := ShaderMaterial.new()
var duplicated_collider: CollisionShape3D
var blend_shape_idx: int
var last_parent: Node3D
var is_separated := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if mesh == null:
		print("No MeshInstance3D found as a child!")
	blend_shape_idx = mesh.find_blend_shape_by_name("Damage")
	
	var material:ShaderMaterial = mesh.get_active_material(0)
	if material != null:
		material.set_shader_parameter("shine_width", 50.0)
		material.set_shader_parameter("shine_color", Color.AQUA)
	
	# OUTLINE SHADER SETUP
	shader_material.shader = OUTLINE
	shader_material.set_shader_parameter("outline_width", 2.0)
	shader_material.set_shader_parameter("outline_color", Color.AQUA)
	shader_material.resource_local_to_scene = true
	
	# NAMING NODES
	name = mesh.name
	collider.name = name + "_Collider"
	
	# SIGNALS
	pinched.connect(car.car_part_pinched)
	collider_duplicated.connect(car.collider_duplicated)
	duplicated_collider = collider.duplicate()
	collider_duplicated.emit(duplicated_collider)
	
	# COLLISIONS SETUP
	freeze = true
	collision_layer = 0b10
	collision_mask = 0b10
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(hit)

func hit(_body: Node):
	Audio.play(Audio.spawn(self, Audio.get_random_sound(Audio.hit_sounds), "Outside"))

func highlight(state := true):
	var material:ShaderMaterial = mesh.get_active_material(0)
	if material == null: return
	if state:
		material.next_pass = shader_material
		material.set_shader_parameter("is_shining", true)
	else:
		material.next_pass = null
		material.set_shader_parameter("is_shining", false)
	
func pinch(tip: Node3D):
	if car != null and name == "Body" and car.parts_pinched < car.colliders.size() - 1:
		last_parent = car.get_parent_node_3d()
		car.reparent(tip)
		car.car_body.freeze = true
		damage(0.2)
	else:
		if duplicated_collider != null:
			duplicated_collider.queue_free()
		self.reparent(tip)
		self.freeze = true
		if not is_separated: pinched.emit()
		damage(0.5)
		is_separated = true
	
	JUNK_PARTICLES.instantiate().init_on_point(get_tree().root, tip)
	return self

func release(angular_velocity: float, velocity: Vector3):
	if car != null and name == "Body" and car.parts_pinched <= car.colliders.size() - 1:
		car.reparent(last_parent)
		car.car_body.freeze = false
		car.car_body.angular_velocity.y = -angular_velocity
		car.car_body.linear_velocity = velocity
	else:
		self.reparent(get_tree().get_root())
		self.freeze = false
		self.angular_velocity.y = -angular_velocity
		self.linear_velocity = velocity

func damage(amount: float) -> void:
	if blend_shape_idx == -1: return
	var current = mesh.get_blend_shape_value(blend_shape_idx)
	mesh.set_blend_shape_value(blend_shape_idx, clamp(current + amount, -1, 1))
