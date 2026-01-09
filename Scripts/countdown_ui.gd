extends Control

@export var text_label: Label
@export var timers_node: Node

func _ready() -> void:
	init_countdown()

func set_countdown(value: int):
	text_label.text = str(value)

func init_countdown():
	set_countdown(timers_node.countdown)
