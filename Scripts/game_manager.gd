extends Node3D

@onready var object_spawn: Marker3D = %ObjectSpawn
@onready var music_player_3d: AudioStreamPlayer3D = $MusicPlayer3D
@onready var countdown: RichTextLabel = $UI/Countdown
@onready var timer: Timer = $Timer
@onready var ui: Control = $UI

const TIME_LABEL = preload("res://Scenes/time_label.tscn")
const HONDA_ACCORD = preload("res://Scenes/honda_accord.tscn")

func _ready() -> void:
	randomize();
	spawn_car(HONDA_ACCORD)

func _process(delta: float) -> void:
	update_timer(timer.time_left)

func update_timer(time_left: float):
	time_left = max(time_left, 0.01) 

	# Calculate frequency: Increase as time approaches zero
	var base_freq = 2.0  # Default frequency
	var max_freq = 10.0  # Maximum frequency
	var freq = base_freq + (max_freq - base_freq) * (1.0 - (time_left / 10.0)) # Adjust scale as needed

	# Format the BBCode with two decimal places and dynamic frequency
	var formatted_text = "[center]%.2f[/center]" % [time_left]
	countdown.text = formatted_text

func trash_collected(result: bool):
	var instance = TIME_LABEL.instantiate()
	var amount = 100 if result else -10
	instance.amount = amount
	ui.add_child(instance)
	var current = timer.time_left
	timer.stop()
	timer.wait_time = max(current + amount, 1)
	timer.start()

func car_destroyed():
	spawn_car()

func spawn_car(car: PackedScene = HONDA_ACCORD):
	var instance : Car = car.instantiate()
	add_child(instance)
	instance.global_position = object_spawn.global_position
	instance.rotation = Vector3(randf(), randf(), randf())
	instance.car_destroyed.connect(car_destroyed)

func _on_timer_timeout() -> void:
	pass # GAME OVER
