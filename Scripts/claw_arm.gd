extends Node3D

@onready var ik_target: Marker3D = $Armature/IKTarget
@onready var skeleton: Skeleton3D = %Skeleton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var look_direction := Vector3(1, 0, 0)

var claw_idx : int
var pinched : bool = true

const MOVE_SPEED = 10
const ROTATION_SPEED = 2.0

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

func claw_released():
	pinched = false

func _physics_process(delta: float) -> void:
	var claw_rotation := skeleton.get_bone_pose_rotation(claw_idx).get_euler()
	if Input.is_action_pressed("rotate_claw_left"):
		claw_rotation.y = fmod(claw_rotation.y - deg_to_rad(ROTATION_SPEED), 360)
		skeleton.set_bone_pose_rotation(claw_idx, Quaternion.from_euler(claw_rotation))
	elif Input.is_action_pressed("rotate_claw_right"):
		claw_rotation.y = fmod(claw_rotation.y + deg_to_rad(ROTATION_SPEED), 360)
		skeleton.set_bone_pose_rotation(claw_idx, Quaternion.from_euler(claw_rotation))
	
	if Input.is_action_just_pressed("pinch"):
		if pinched:
			animation_player.play("release")
		else:
			animation_player.play("pinch")
			
	if Input.is_action_pressed("up"):
		ik_target.global_position.y += delta * MOVE_SPEED
	elif Input.is_action_pressed("front"):
		ik_target.global_position.x += look_direction.normalized().x * delta * MOVE_SPEED
		ik_target.global_position.z += look_direction.normalized().z * delta * MOVE_SPEED
		
	if Input.is_action_pressed("down"):
		ik_target.global_position.y -= delta * MOVE_SPEED
	elif Input.is_action_pressed("back"):
		ik_target.global_position.x -= look_direction.normalized().x * delta * MOVE_SPEED
		ik_target.global_position.z -= look_direction.normalized().z * delta * MOVE_SPEED
