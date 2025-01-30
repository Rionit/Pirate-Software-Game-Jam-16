extends Node
class_name Audio

const ONE_SHOT_PLAYER = preload("res://Scenes/one_shot_player.tscn")

static func play(player: AudioStreamPlayer3D, sound: AudioStream = null, 
volume: float = 1.0, pitch: float = 1.0):
	if player.playing and sound == null:
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
