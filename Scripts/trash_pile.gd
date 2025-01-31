extends StaticBody3D
class_name TrashPile

signal trash_collected(result: bool)

const JUNK_PARTICLES = preload("res://Scenes/junk_particles.tscn")
const GLASS_CRASH = preload("res://Sounds/SFX/glass_crash.mp3")
const BIG_CRASH_W_CAT = preload("res://Sounds/SFX/big_crash_w_cat.mp3")
const SOFT_CRASH = preload("res://Sounds/SFX/soft_crash.mp3")
const BATTERY_CRASH = preload("res://Sounds/SFX/battery_crash.mp3")
const AXLE_CRASH = preload("res://Sounds/SFX/axle_crash.mp3")
const METAL_PIPE = preload("res://Sounds/SFX/metal_pipe.mp3")
const METAL_CRASH = preload("res://Sounds/SFX/metal_crash.mp3")

enum TrashTypes {METAL, GLASS, INTERIOR, ENGINE, BATTERY, AXLE}

@export var area: Area3D
@export var trash_type: TrashTypes

func _ready() -> void:
	area.connect("body_entered", trash_entered)

func play_sound():
	match trash_type:
		TrashTypes.ENGINE:
			Audio.play(Audio.spawn(self, BIG_CRASH_W_CAT, "Outside"))
		TrashTypes.GLASS:
			Audio.play(Audio.spawn(self, GLASS_CRASH, "Outside"))
		TrashTypes.INTERIOR:
			Audio.play(Audio.spawn(self, SOFT_CRASH, "Outside"))
		TrashTypes.BATTERY:
			Audio.play(Audio.spawn(self, BATTERY_CRASH, "Outside"))
		TrashTypes.AXLE:
			if randf() > 0.9:
				Audio.play(Audio.spawn(self, METAL_PIPE, "Outside"))
			else:
				Audio.play(Audio.spawn(self, AXLE_CRASH, "Outside"))
		TrashTypes.METAL:
			Audio.play(Audio.spawn(self, METAL_CRASH, "Outside"))
			

func trash_entered(trash: Node3D):
	if trash is CarPart:
		play_sound()
		JUNK_PARTICLES.instantiate().init_on_mesh(get_tree().root, trash.mesh)
		trash_collected.emit(trash.type == trash_type)
		trash.queue_free()
