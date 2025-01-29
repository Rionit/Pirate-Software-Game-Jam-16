extends Node3D

@onready var object_spawn: Marker3D = %ObjectSpawn

const HONDA_ACCORD = preload("res://Scenes/honda_accord.tscn")

func _ready() -> void:
	randomize();
	spawn_car(HONDA_ACCORD)

func car_destroyed():
	spawn_car()

func spawn_car(car: PackedScene = HONDA_ACCORD):
	var instance : Car = car.instantiate()
	add_child(instance)
	instance.global_position = object_spawn.global_position
	instance.rotation = Vector3(randf(), randf(), randf())
	instance.car_destroyed.connect(car_destroyed)
