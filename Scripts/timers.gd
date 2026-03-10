extends Node

@export var start_button: Button
@export var import_button: Button
@export var reload_hint: Label

@export var countdown: int
@export var countdown_ui: Control
@export var time_manager: RGCTimeManager
@export var track_manager: RGCTrackManager

@export var note_spawner_timer: Timer
@export var audio_play_timer: Timer

@export var continue_timer: Timer

var timer_count: int = 0

func _on_start_button_pressed() -> void:
	if track_manager.note_datas.is_empty():
		push_error("未加载谱面文件！")
		return
	
	start_button.disabled = true
	import_button.disabled = true
	reload_hint.visible = true
	note_spawner_timer.start()
	audio_play_timer.start()

func _on_note_spawner_timer_timeout() -> void:
	time_manager.start_game.emit()

func _on_continue_timer_timeout() -> void:
	if timer_count < countdown:
		timer_count += 1
		countdown_ui.set_countdown(countdown - timer_count)
		return
	
	continue_timer.stop()
	timer_count = 0
	countdown_ui.visible = false
	get_tree().paused = false
	time_manager.continue_game()
