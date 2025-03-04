@tool
extends EditorPlugin

## Plugin for automatically creating a [Car] with its [CarPart]s by assigning
## scripts, renaming nodes, changing the material and setting up values. 
## [br] [br]
## All you need to do to create a [Car] is to select the root
## and press the [i]Make Car[/i] button.

## The [CarPart] script that is assigned to each car part.
const CAR_PART_SCRIPT: Script = preload("res://Scripts/car_part.gd")
## The [Car] script that is assigned to the car.
const CAR_SCRIPT: Script = preload("res://Scripts/car.gd")
## The PSX shader that is assigned to the new [ShaderMaterial]
const PSX = preload("res://Shaders/psx.gdshader")

## The button in [constant EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU]
## that creates the [Car].
var assign_button: Button # TODO: maybe change this to custom UI with sliders etc.

func _enter_tree():
	# Create a button and add it to the editor's toolbar.
	assign_button = Button.new()
	assign_button.text = "Make Car"
	assign_button.connect("pressed", Callable(self, "_on_assign_button_pressed"))
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, assign_button)

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, assign_button)
	assign_button.queue_free()

## Assigns the corresponding trash type [constant Global.TrashTypes] to the [CarPart]
func assign_trash_type(car_part: CarPart):
	var sliced := car_part.name.split("-", true, 1)
	var prefix := sliced[0]
	var rest := sliced[1]
	
	match prefix:
		"metal":
			car_part.type = Global.TrashTypes.METAL
		"battery":
			car_part.type = Global.TrashTypes.BATTERY
		"engine":
			car_part.type = Global.TrashTypes.ENGINE
		"tire":
			car_part.type = Global.TrashTypes.TIRE
		"glass":
			car_part.type = Global.TrashTypes.GLASS
		"axle":
			car_part.type = Global.TrashTypes.AXLE
		"interior":
			car_part.type = Global.TrashTypes.INTERIOR
	
	car_part.name = rest

## Assigns the [member CarPart.mesh] to the [CarPart]
func assign_mesh(car_part: CarPart):
	var grand_children = car_part.get_children()
	for grand_child in grand_children:
		if grand_child is MeshInstance3D:
			car_part.mesh = grand_child

## Changes the default [StandardMaterial3D] to a new PSX [ShaderMaterial].
## It also transfers the old texture to this new material.
func change_material(car_part: CarPart):
	var current_mat = car_part.mesh.get_active_material(0)
	if current_mat is StandardMaterial3D:
		var psx_shader_mat = ShaderMaterial.new()
		psx_shader_mat.shader = PSX
		psx_shader_mat.set_shader_parameter("albedo", current_mat.albedo_texture)
		car_part.mesh.mesh.surface_set_material(0, psx_shader_mat)
	else:
		print(car_part.name + " does not have a StandardMaterial3D! Maybe it is already converted?")

## The function called after pressing the [i]Make Car[/i] button. It calls 
## all of the necessary functions to create a [Car]. 
func _on_assign_button_pressed():
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	if selection.is_empty():
		print("Please select the main parent in the scene tree.")
		return

	var parent_node = selection[0]
	parent_node.set_script(CAR_SCRIPT)
	print("Car script assigned to ", parent_node.name)
	
	# Load or reference the script you want to assign.
	for child in parent_node.get_children():
		if child is RigidBody3D:
			child.set_script(CAR_PART_SCRIPT)
			child.name = child.name.trim_suffix("-rigid")
			assign_trash_type(child)
			assign_mesh(child)
			change_material(child)
			
	print("CarPart script assigned to all children of ", parent_node.name)
