extends GPUParticles3D
class_name JunkParticles

func _ready() -> void:
	self.connect("finished", destroy)

func destroy():
	self.queue_free()

func init_on_mesh(root: Node, mesh: MeshInstance3D):
	root.add_child(self)
	var height = mesh.get_aabb().size.y / 2
	global_position = mesh.global_position + Vector3(0, height, 0)
	restart()

func init_on_point(root: Node, point):
	root.add_child(self)
	global_position = point.global_position
	restart()
