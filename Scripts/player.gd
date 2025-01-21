extends Node3D

@onready var machine: Node3D = $Machine
@onready var claw_arm: Node3D = $Machine/ClawArm

const PAN_SPEED = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	# We create a local variable to store the input direction.
	if Input.is_action_pressed("left"):
		rotate_machine(PAN_SPEED*delta)
	if Input.is_action_pressed("right"):
		rotate_machine(-PAN_SPEED*delta)

func rotate_machine(angle):
	machine.rotate_y(deg_to_rad(angle))
	claw_arm.look_direction = claw_arm.look_direction.rotated(Vector3.UP, deg_to_rad(angle))
