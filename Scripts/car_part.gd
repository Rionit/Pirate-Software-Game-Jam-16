extends RigidBody3D
class_name CarPart

const JUNK_PARTICLES = preload("res://Scenes/junk_particles.tscn")
const SHINE = preload("res://Shaders/shine.gdshader")

signal collider_duplicated(_collider: CollisionShape3D)
signal pinched

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var car: Car = $"../.."

@export var mesh: MeshInstance3D

var shader_material := ShaderMaterial.new()
var duplicated_collider: CollisionShape3D
var blend_shape_idx: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if mesh == null:
		print("No MeshInstance3D found as a child!")
	blend_shape_idx = mesh.find_blend_shape_by_name("Damage")
	
	# SHINE SHADER SETUP
	shader_material.shader = SHINE
	shader_material.set_shader_parameter("shine_width", 50.0)
	shader_material.set_shader_parameter("shine_color", Color.AQUA)
	shader_material.resource_local_to_scene = true
	
	# FADE DITHER
	var material = mesh.get_active_material(0)
	material.distance_fade_mode = StandardMaterial3D.DISTANCE_FADE_PIXEL_DITHER
	material.distance_fade_max_distance = 1.0  # 1 meter
	material.distance_fade_min_distance = 0.0  # Start fading at 0 meters
	
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

func highlight(state := true):
	if state:
		mesh.get_active_material(0).next_pass = shader_material
	else:
		mesh.get_active_material(0).next_pass = null
	
func pinch(tip: Node3D):
	if duplicated_collider != null:
		duplicated_collider.queue_free()

	self.reparent(tip)
	self.freeze = true
	JUNK_PARTICLES.instantiate().init_on_point(get_tree().root, tip)
	damage(1.0)
	pinched.emit()
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
	if blend_shape_idx == -1: return
	mesh.set_blend_shape_value(blend_shape_idx, clamp(amount, -1, 1))
