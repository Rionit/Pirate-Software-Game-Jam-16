@tool
extends EditorPlugin

const res = preload("res://addons/script_assigner/target_script.tres")
var target_script: Script
var assign_button: Button

func _enter_tree():
	# Create a button and add it to the editor's toolbar.
	assign_button = Button.new()
	assign_button.text = "Assign Child Script"
	assign_button.connect("pressed", Callable(self, "_on_assign_button_pressed"))
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, assign_button)

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, assign_button)
	assign_button.queue_free()

func _on_assign_button_pressed():
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	if selection.is_empty():
		print("Please select a node in the scene tree.")
		return

	target_script = res.target_script
	var parent_node = selection[0]
	# Load or reference the script you want to assign.
	for child in parent_node.get_children():
		if child is Node:
			print(child.name)
			child.set_script(target_script)
	print("Script assigned to all children of ", parent_node.name)
