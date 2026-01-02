extends Node

@export var time_manager: RGCTimeManager
@export var track_manager: RGCTrackManager

@export var note_spawner_timer: Timer
@export var audio_play_timer: Timer
@export var monitor_timer: Timer

func _on_start_button_pressed() -> void:
	if track_manager.note_datas.is_empty():
		push_error("未加载谱面文件！")
		return
	
	note_spawner_timer.start()
	audio_play_timer.start()

func _on_note_spawner_timer_timeout() -> void:
	time_manager.start_game.emit()

func _on_monitor_timer_timeout() -> void:
	print(time_manager.elasped_time)
