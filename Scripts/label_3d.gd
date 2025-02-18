@tool
extends Node3D
class_name MyLabel3D

@export var title : String

@onready var label: Label = $SubViewport/GUI/Label
@onready var quad: MeshInstance3D = $Quad
@onready var sub_viewport: SubViewport = $SubViewport

var alpha = 1.0

const fade_point = 5.0

func _ready() -> void:
	quad.get_surface_override_material(0).albedo_texture = sub_viewport.get_texture()
	label.text = title

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		label.text = title
	else:
		# Get positions and ignore the y (height) component
		var tip_pos = Global.tip.global_position
		var my_pos = global_position
		var horizontal_distance = Vector2(tip_pos.x - my_pos.x, tip_pos.z - my_pos.z).length()

		# When horizontal_distance is 0, alpha = 1.0; when it's fade_point or more, alpha = 0.0.
		alpha = clamp(1.0 - (horizontal_distance / fade_point), 0.0, 1.0)
		quad.get_surface_override_material(0).albedo_color.a = alpha
