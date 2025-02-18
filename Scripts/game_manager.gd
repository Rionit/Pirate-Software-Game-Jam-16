extends Node3D

@onready var object_spawn: Marker3D = %ObjectSpawn
@onready var music_player_3d: AudioStreamPlayer3D = $MusicPlayer3D
@onready var countdown: RichTextLabel = $UI/Countdown
@onready var timer: Timer = $Timer
@onready var sec_timer: Timer = $SecondTimer
@onready var ui: Control = $UI

const GAME_OVER_SCREEN = preload("res://Scenes/game_over_screen.tscn")
const TIME_LABEL = preload("res://Scenes/time_label.tscn")
const HONDA_ACCORD = preload("res://Scenes/honda_accord.tscn")
const ERROR = preload("res://Sounds/SFX/error.mp3")
const SUCCESS = preload("res://Sounds/SFX/success.wav")

@export var start_time_amount : int = 100
@export var successful_sort : int = 20
@export var bad_sort : int = -20
var total_time : int = 0

func _ready() -> void:
	randomize();
	spawn_car(HONDA_ACCORD)
	sec_timer.start()
	timer.wait_time = start_time_amount
	timer.start()

func _process(_delta: float) -> void:
	update_timer(timer.time_left)

func update_timer(time_left: float):
	time_left = max(time_left, 0.01) 

	## Calculate frequency: Increase as time approaches zero
	#var base_freq = 2.0  # Default frequency
	#var max_freq = 10.0  # Maximum frequency
	#var freq = base_freq + (max_freq - base_freq) * (1.0 - (time_left / 10.0)) # Adjust scale as needed

	# Format the BBCode with two decimal places and dynamic frequency
	var formatted_text = "[tornado radius=10.0 freq=1.0 connected=1][center]%.2f[/center][/tornado]" % [time_left]
	countdown.text = formatted_text

func trash_collected(result: bool):
	var instance = TIME_LABEL.instantiate()
	var amount = successful_sort if result else bad_sort
	instance.amount = amount
	ui.add_child(instance)
	var current = timer.time_left
	timer.stop()
	timer.wait_time = max(current + amount, 1)
	timer.start()
	
	if result:
		Audio.play(Audio.spawn(self, SUCCESS, "SFX"))
	else:
		Audio.play(Audio.spawn(self, ERROR, "SFX"))
		
func car_destroyed():
	spawn_car()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func spawn_car(car: PackedScene = HONDA_ACCORD):
	var instance : Car = car.instantiate()
	add_child(instance)
	instance.global_position = object_spawn.global_position
	instance.rotation = Vector3(randf(), randf(), randf())
	instance.car_destroyed.connect(car_destroyed)

func _on_timer_timeout() -> void:
	ui.queue_free()
	var instance = GAME_OVER_SCREEN.instantiate()
	instance.elapsed_time = total_time / 10.0
	add_child(instance)

func _on_second_timer_timeout() -> void:
	total_time += 1
