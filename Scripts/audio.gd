extends Node
class_name Audio

const ONE_SHOT_PLAYER = preload("res://Scenes/one_shot_player.tscn")

const HIT_1 = preload("res://Sounds/SFX/hit_1.mp3")
const HIT_2 = preload("res://Sounds/SFX/hit_2.mp3")
const HIT_3 = preload("res://Sounds/SFX/hit_3.mp3")
const HIT_4 = preload("res://Sounds/SFX/hit_4.mp3")
const HIT_5 = preload("res://Sounds/SFX/hit_5.mp3")
const HIT_6 = preload("res://Sounds/SFX/hit_6.mp3")
const HIT_7 = preload("res://Sounds/SFX/hit_7.mp3")
const HIT_8 = preload("res://Sounds/SFX/hit_8.mp3")
const HIT_9 = preload("res://Sounds/SFX/hit_9.mp3")

static var hit_sounds: Array[AudioStream] = [HIT_1, HIT_2, HIT_3, HIT_4, HIT_5, HIT_6, HIT_7, HIT_8, HIT_9]

static func get_random_sound(array: Array[AudioStream]) -> AudioStream:
	if array.is_empty():
		return null
	return array[randi() % array.size()]

static func play(player: AudioStreamPlayer3D, sound: AudioStream = null, 
volume: float = 1.0, pitch: float = 1.0):
	if player.playing:
		return
	
	if sound != null:
		player.stream = sound
	
	player.pitch_scale = pitch
	player.max_db = volume
	
	player.play()
	
static func spawn(where: Node3D, stream: AudioStream, bus: String) -> OneShotPlayer:
	var instance = ONE_SHOT_PLAYER.instantiate()
	where.add_child(instance)
	instance.global_position = where.global_position
	instance.stream = stream
	instance.bus = bus
	return instance
