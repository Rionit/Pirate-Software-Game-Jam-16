extends Node3D

@onready var machine: Node3D = $Machine
@onready var claw_arm: Node3D = $Machine/ClawArm

const PAN_SPEED = 50
const ACCELERATION = 0.5
const DESCELERATION = 50

var angular_velocity := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	if Input.is_action_pressed("left"):
		angular_velocity = min(angular_velocity + ACCELERATION, PAN_SPEED)
	elif Input.is_action_pressed("right"):
		angular_velocity = max(angular_velocity - ACCELERATION, -PAN_SPEED)
	else:
		angular_velocity = move_toward(angular_velocity, 0, delta * DESCELERATION)
	
	rotate_machine(angular_velocity * delta)

func rotate_machine(angle):
	machine.rotate_y(deg_to_rad(angle))
	claw_arm.look_direction = claw_arm.look_direction.rotated(Vector3.UP, deg_to_rad(angle))
