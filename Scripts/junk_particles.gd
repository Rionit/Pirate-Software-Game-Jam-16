extends GPUParticles3D

func _ready() -> void:
	self.connect("finished", destroy)

func destroy():
	self.queue_free()
