extends Node3D

@onready var machine: Node3D = $Machine
@onready var claw_arm: ClawArm = $Machine/ClawArm
@onready var claw_cam: Camera3D = %ClawCam
@onready var claw_cam_viewport: SubViewport = $Machine/ClawCamViewport
@onready var machine_rotation_sfx: AudioStreamPlayer3D = $Machine/MachineRotationSFX
@onready var machine_hiss_sfx: AudioStreamPlayer3D = $Machine/MachineHissSFX
@onready var engine_sfx: AudioStreamPlayer3D = $Machine/EngineSFX
@onready var movement_sfx: AudioStreamPlayer3D = $Machine/MovementSFX

const MOVEMENT_START = preload("res://Sounds/SFX/movement_start.mp3")
const MOVEMENT_STOP = preload("res://Sounds/SFX/movement_stop.mp3")
const PAN_SPEED = 50
const ACCELERATION = 0.5
const DESCELERATION = 50

var angular_velocity := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	claw_cam.look_at_from_position(claw_arm.claw_cam_position.global_position, 
								   claw_arm.claw_cam_direction.global_position,
								   claw_arm.claw_cam_up.global_position - claw_arm.claw_cam_position.global_position)

func _physics_process(delta):
	if Input.is_action_pressed("left"):
		angular_velocity = min(angular_velocity + ACCELERATION, PAN_SPEED)
		
		# SFX
		if not machine_rotation_sfx.playing: 
			Audio.play(machine_rotation_sfx, null, 1.0, randf_range(0.8, 1.0))
			Audio.play(movement_sfx, MOVEMENT_START, 1.0, randf_range(0.8, 1.2))
	elif Input.is_action_pressed("right"):
		angular_velocity = max(angular_velocity - ACCELERATION, -PAN_SPEED)
		
		# SFX
		if not machine_rotation_sfx.playing: 
			Audio.play(machine_rotation_sfx)
			Audio.play(movement_sfx, MOVEMENT_START, 1.0, randf_range(0.8, 1.2))
	else:
		angular_velocity = move_toward(angular_velocity, 0, delta * DESCELERATION)
		machine_rotation_sfx.stop()
	
	if Input.is_action_just_released("right") or Input.is_action_just_released("left"):
		Audio.play(movement_sfx, MOVEMENT_STOP, 1.0, randf_range(0.8, 1.2))
		if randf() > 0.1:
			Audio.play(machine_hiss_sfx, null, randf_range(-3.0, 0.0), randf_range(0.8, 1.2))
	
	claw_arm.velocity.z = -deg_to_rad(angular_velocity) * 10.0
	rotate_machine(angular_velocity * delta)

func rotate_machine(angle: float):
	machine.rotate_y(deg_to_rad(angle))

func _on_engine_start_sfx_finished() -> void:
	engine_sfx.play()
