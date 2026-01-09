extends Control

@export var countdown_ui: Control
@export var time_manager: RGCTimeManager
@export var continue_timer: Timer

func _ready() -> void:
	if get_tree().paused:
		get_tree().paused = false

func _on_pause_button_pressed() -> void:
	visible = true
	get_tree().paused = true
	time_manager.pause_game()

func _on_continue_button_pressed() -> void:
	visible = false
	countdown_ui.visible = true
	countdown_ui.init_countdown()
	continue_timer.start()

func _on_reload_button_pressed() -> void:
	get_tree().reload_current_scene()
	print("重载成功")
