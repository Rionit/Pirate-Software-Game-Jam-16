extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var amount: int

func _ready() -> void:
	text = str(amount)
	animation_player.play("pop")

func destroy():
	queue_free()
