extends Node3D

@onready var ik_target: Marker3D = $Armature/IKTarget
@onready var skeleton: Skeleton3D = %Skeleton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tip: Area3D = %Tip

@export var look_direction := Vector3(1, 0, 0)

var pinched_part: RigidBody3D = null
var close_part: RigidBody3D = null
var claw_idx: int
var pinched := true

var angular_velocity := 0.0
var velocity := Vector3.ZERO

const MAX_MOVE_SPEED = 5
const MAX_ROTATION_SPEED = 5.0
const ACCELERATION = 0.05
const DESCELERATION = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_claw()

func init_claw():
	claw_idx = skeleton.find_bone("Claw") 
	var claw_rotation := skeleton.get_bone_pose_rotation(claw_idx).get_euler()
	claw_rotation.y = deg_to_rad(28.5) # roll
	claw_rotation.x = 0 				# pitch
	claw_rotation.z = deg_to_rad(90) 	# yaw
	skeleton.set_bone_pose_rotation(claw_idx, Quaternion.from_euler(claw_rotation))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func claw_pinched():
	pinched = true
	
	if close_part != null:
		pinched_part = close_part
		pinched_part.reparent(tip)
		pinched_part.freeze = true

func claw_released():
	pinched = false
	if pinched_part != null: 
		pinched_part.reparent(get_tree().get_root())
		pinched_part.freeze = false
		pinched_part = null

func pinch() -> void:
	if pinched:
		animation_player.play("release")
	else:
		animation_player.play("pinch")

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("rotate_claw_left"):
		angular_velocity = min(angular_velocity + ACCELERATION, MAX_ROTATION_SPEED)
	elif Input.is_action_pressed("rotate_claw_right"):
		angular_velocity = max(angular_velocity - ACCELERATION, -MAX_ROTATION_SPEED)
	else:
		angular_velocity = move_toward(angular_velocity, 0, delta * DESCELERATION)
	
	if Input.is_action_just_pressed("pinch"):
		pinch()
	
	var dir = look_direction.normalized()
	
	if Input.is_action_pressed("up"):
		velocity.y = min(velocity.y + ACCELERATION, MAX_MOVE_SPEED)
	elif Input.is_action_pressed("down"):
		velocity.y = max(velocity.y - ACCELERATION, -MAX_MOVE_SPEED)
	elif Input.is_action_pressed("front"):
		velocity.x = min(velocity.x + ACCELERATION, MAX_MOVE_SPEED)
	elif Input.is_action_pressed("back"):
		velocity.x = max(velocity.x - ACCELERATION, -MAX_MOVE_SPEED)
	else:
		velocity = lerp(velocity, Vector3.ZERO, delta * DESCELERATION)
	
	# ROTATION
	var claw_rotation := skeleton.get_bone_pose_rotation(claw_idx).get_euler()
	claw_rotation.y = fmod(claw_rotation.y + deg_to_rad(angular_velocity), 360)
	skeleton.set_bone_pose_rotation(claw_idx, Quaternion.from_euler(claw_rotation))
	
	# POSITION
	ik_target.position += velocity * delta

func tip_entered_body(body: Node3D) -> void:
	print("Tip entered " + body.name)
	if body is CarPart:
		close_part = body

func tip_exited_body(body: Node3D) -> void:
	print("Tip exited " + body.name)
	if close_part == body:
		close_part = null
