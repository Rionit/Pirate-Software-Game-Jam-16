extends StaticBody3D
class_name TrashPile

enum TrashTypes {METAL, GLASS, INTERIOR, MOTOR, BATTERY}

@export var area: Area3D
@export var trash_type: TrashTypes

func _ready() -> void:
	area.connect("body_entered", trash_entered)

func trash_entered(trash: Node3D):
	print("yippeee")
