extends Control

var elapsed_time: float
@onready var time: Label = $VBoxContainer/Time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	time.text = "You have played for: %.2f" % [elapsed_time]

func _on_button_pressed() -> void:
	print("yes")
	get_tree().paused = false
	get_tree().reload_current_scene()
