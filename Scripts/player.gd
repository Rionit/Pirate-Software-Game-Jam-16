extends Node3D

@onready var machine: Node3D = $Machine
@onready var claw_arm: ClawArm = $Machine/ClawArm
@onready var claw_cam: Camera3D = %ClawCam
@onready var claw_cam_viewport: SubViewport = $Machine/ClawCamViewport

const PAN_SPEED = 50
const ACCELERATION = 0.5
const DESCELERATION = 50

var angular_velocity := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	claw_cam.look_at_from_position(claw_arm.claw_cam_position.global_position, 
								   claw_arm.claw_cam_direction.global_position,
								   claw_arm.claw_cam_up.global_position - claw_arm.claw_cam_position.global_position)

func _physics_process(delta):
	if Input.is_action_pressed("left"):
		angular_velocity = min(angular_velocity + ACCELERATION, PAN_SPEED)
	elif Input.is_action_pressed("right"):
		angular_velocity = max(angular_velocity - ACCELERATION, -PAN_SPEED)
	else:
		angular_velocity = move_toward(angular_velocity, 0, delta * DESCELERATION)
	
	claw_arm.velocity.z = -deg_to_rad(angular_velocity) * 10.0
	rotate_machine(angular_velocity * delta)

func rotate_machine(angle: float):
	machine.rotate_y(deg_to_rad(angle))
