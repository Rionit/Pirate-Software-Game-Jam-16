@tool
extends EditorPlugin

var car_part_script: Script = preload("res://Scripts/car_part.gd")
var car_script: Script = preload("res://Scripts/car.gd")
var assign_button: Button

func _enter_tree():
	# Create a button and add it to the editor's toolbar.
	assign_button = Button.new()
	assign_button.text = "Make Car"
	assign_button.connect("pressed", Callable(self, "_on_assign_button_pressed"))
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, assign_button)

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, assign_button)
	assign_button.queue_free()

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

func assign_mesh(car_part: CarPart):
	var grand_children = car_part.get_children()
	for grand_child in grand_children:
		if grand_child is MeshInstance3D:
			car_part.mesh = grand_child

func _on_assign_button_pressed():
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	if selection.is_empty():
		print("Please select the main parent in the scene tree.")
		return

	var parent_node = selection[0]
	parent_node.set_script(car_script)
	print("Car script assigned to ", parent_node.name)
	
	# Load or reference the script you want to assign.
	for child in parent_node.get_children():
		if child is RigidBody3D:
			child.set_script(car_part_script)
			child.name = child.name.trim_suffix("-rigid")
			assign_trash_type(child)
			assign_mesh(child)
			#change_material(child) # TODO: create this function
			
	print("CarPart script assigned to all children of ", parent_node.name)
