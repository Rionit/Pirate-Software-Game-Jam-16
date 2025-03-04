extends Node3D
class_name ClawArm

## ClawArm
##
## Represents a mechanical claw arm used for grabbing and manipulating objects.
## Handles movement, rotation, pinching mechanics, and sound effects.

# Preloaded sound effects for claw and machine movements.
const HISS_2 = preload("res://Sounds/SFX/hiss_2.mp3")
const CLAW_OPEN = preload("res://Sounds/SFX/claw_open.mp3")
const CLAW_CLOSE = preload("res://Sounds/SFX/claw_close.mp3")
const HYDRAULIC_HOIST = preload("res://Sounds/SFX/hydraulic_hoist.mp3")
const ELECTRIC_HOIST = preload("res://Sounds/SFX/electric_hoist.mp3")
const ACTUATOR_FORWARD = preload("res://Sounds/SFX/actuator_forward.mp3")
const ACTUATOR_BACKWARD = preload("res://Sounds/SFX/actuator_backward.mp3")

# Audio players for different machine sounds.
@onready var claw_rotation_sfx: AudioStreamPlayer3D = %ClawRotationSFX
@onready var machine_movement_sfx: AudioStreamPlayer3D = %MachineMovementSFX
@onready var machine_lift_sfx: AudioStreamPlayer3D = %MachineLiftSFX

# Animation player for controlling claw animations.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Markers for camera positioning relative to the claw.
@onready var claw_cam_direction: Marker3D = %ClawCamDirection
@onready var claw_cam_position: Marker3D = %ClawCamPosition
@onready var claw_cam_up: Marker3D = %ClawCamUp

# IK system components for claw movement and physics.
@onready var ik_body: CharacterBody3D = %IKBody
@onready var ik_target: Marker3D = %IkTarget

# The skeleton of the claw mechanism.
@onready var skeleton: Skeleton3D = %Skeleton

## Area3D component representing the claw's tip.
@onready var tip: Area3D = %Tip

## 3D label displaying the type of the pinched object.
@onready var type_label: MyLabel3D = %TypeLabel

## Array of sound effects played when pinching objects.
@export var pinch_sounds: Array[AudioStream]

## Reference to the currently pinched car part.
var pinched_part: CarPart = null
## Reference to the nearest car part that can be pinched.
var close_part: CarPart = null

## Index of the claw bone in the skeleton.
var claw_idx: int
## Tracks whether the claw is currently pinching an object.
var pinched := true

## Movement and rotation physics variables.
var angular_velocity := 0.0
var velocity := Vector3.ZERO

# Speed and acceleration constants.
var max_speed = 10.0 
var min_speed = 0.0 
const MAX_MOVE_SPEED = 5
const MAX_ROTATION_SPEED = 5.0
const ACCELERATION = 0.05
const DESCELERATION = 10

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_claw()
	Global.tip = tip

## Initializes the claw's default rotation.
func init_claw():
	claw_idx = skeleton.find_bone("Claw") 
	var claw_rotation := skeleton.get_bone_pose_rotation(claw_idx).get_euler()
	claw_rotation.y = deg_to_rad(28.5)  # Roll
	claw_rotation.x = 0  # Pitch
	claw_rotation.z = deg_to_rad(90)  # Yaw
	skeleton.set_bone_pose_rotation(claw_idx, Quaternion.from_euler(claw_rotation))

## Handles the logic for pinching an object with the claw.
func claw_pinched():
	pinched = true
	if close_part != null:
		pinched_part = close_part.pinch(tip)
		Audio.play(Audio.spawn(tip, Audio.get_random_sound(pinch_sounds), "Outside"), null, -2.0)
		type_label.text = Global.TrashTypes.keys()[pinched_part.type]
		Global.is_pinching_part = true

## Handles the logic for releasing an object from the claw.
func claw_released():
	pinched = false
	if pinched_part != null:
		pinched_part.release(0.0, velocity.rotated(Vector3.UP, get_parent_node_3d().rotation.y))
		pinched_part = null
		type_label.text = ""
		Global.is_pinching_part = false

## Transitions smoothly between claw animations.
func transition_claw(from, to):
	var current_pos = animation_player.current_animation_position
	var length = animation_player.get_animation(from).length
	var progress = current_pos / length

	animation_player.play(to)
	animation_player.seek((1.0 - progress), true)

## Toggles between pinching and releasing states based on input.
func switch_claw() -> void:
	if animation_player.is_playing():
		match animation_player.current_animation:
			"pinch": transition_claw("pinch", "release")
			"release": transition_claw("release", "pinch")
	elif pinched:
		Audio.play(Audio.spawn(tip, HISS_2, "Machine"), null, 1.0, randf_range(0.8, 1.2))
		Audio.play(Audio.spawn(tip, CLAW_OPEN, "Machine"), null, 1.0, randf_range(1.0, 1.2))
		animation_player.play("release")
	else:
		Audio.play(Audio.spawn(tip, CLAW_CLOSE, "Machine"), null, 1.0, randf_range(0.8, 1.0))
		animation_player.play("pinch")

## Handles physics updates for movement and rotation.
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("rotate_claw_left"):
		angular_velocity = min(angular_velocity + ACCELERATION, MAX_ROTATION_SPEED)
		
		# SFX
		if not claw_rotation_sfx.playing:
			Audio.play(claw_rotation_sfx, ACTUATOR_BACKWARD)
	elif Input.is_action_pressed("rotate_claw_right"):
		angular_velocity = max(angular_velocity - ACCELERATION, -MAX_ROTATION_SPEED)
		
		# SFX
		if not claw_rotation_sfx.playing:
			Audio.play(claw_rotation_sfx, ACTUATOR_FORWARD)
	else:
		claw_rotation_sfx.stop()
		angular_velocity = move_toward(angular_velocity, 0, delta * DESCELERATION)
	
	if Input.is_action_pressed("up"):
		velocity.y = min(velocity.y + ACCELERATION, MAX_MOVE_SPEED)
		
		# SFX
		if not machine_lift_sfx.playing: 
			Audio.play(machine_lift_sfx)
	elif Input.is_action_pressed("down"):
		velocity.y = max(velocity.y - ACCELERATION, -MAX_MOVE_SPEED)
		
		# SFX
		if not machine_lift_sfx.playing: 
			Audio.play(machine_lift_sfx, null, 1.0, 0.7)
	else:
		machine_lift_sfx.stop()
		velocity.y = move_toward(velocity.y, 0, delta * DESCELERATION)
		
	if Input.is_action_pressed("front"):
		velocity.x = min(velocity.x + ACCELERATION, MAX_MOVE_SPEED)
		
		if not machine_movement_sfx.playing: 
			Audio.play(machine_movement_sfx, ELECTRIC_HOIST, 1.0, 1.0)
	elif Input.is_action_pressed("back"):
		velocity.x = max(velocity.x - ACCELERATION, -MAX_MOVE_SPEED)
		
		if not machine_movement_sfx.playing: 
			Audio.play(machine_movement_sfx, ELECTRIC_HOIST, 1.0, 0.8)
	else:
		machine_movement_sfx.stop()
		velocity.x = move_toward(velocity.x, 0, delta * DESCELERATION)
	
	# BOUNDS
	var height = ik_target.global_position.y + velocity.y * delta
	var distance = Vector2(ik_target.global_position.x, ik_target.global_position.z).length()
	distance += velocity.x * delta
	if distance <= 2.0 or distance >= 22.5 or height <= 0.0 or height >= 10.0:
		velocity = Vector3.ZERO

	# ROTATION
	var claw_rotation := skeleton.get_bone_pose_rotation(claw_idx).get_euler()
	claw_rotation.y = fmod(claw_rotation.y + deg_to_rad(angular_velocity), 360)
	skeleton.set_bone_pose_rotation(claw_idx, Quaternion.from_euler(claw_rotation))
	
	# POSITION - we just want x and y cause z is controled in player
	ik_target.position.x += velocity.x * delta
	ik_target.position.y += velocity.y * delta
	
	var ik_target_dir = (ik_target.global_position - ik_body.global_position)
	var distance_to_target = ik_target_dir.length() 
	var speed_factor = clamp(distance_to_target / 1.0, 0.0, 1.0)  

	# Calculate the speed based on the distance to the target
	var speed = lerp(min_speed, max_speed, speed_factor)

	# Set the velocity towards the target
	ik_body.velocity = ik_target_dir.normalized() * speed

	# Move the IK body
	ik_body.move_and_slide()

## Handles input events for toggling the claw's state.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pinch"):
		switch_claw()

## Called when the claw tip enters a body, checking for pinchable objects.
func tip_entered_body(body: Node3D) -> void:
	if body is CarPart and pinched_part == null and close_part == null:
		if close_part != null:
			close_part.highlight(false)
		close_part = body
		close_part.highlight()

## Called when the claw tip exits a body, removing highlight effects.
func tip_exited_body(body: Node3D) -> void:
	if close_part == body:
		close_part.highlight(false)
		close_part = null
