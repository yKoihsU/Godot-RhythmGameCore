extends Node
class_name RGCTimeManager

signal start_game()

## 音符生成器倒计时
@export var note_spawner_timer: Timer

## 音乐播放倒计时
@export var audio_play_timer: Timer

var cache_start_time: int
var elasped_time: int

## 音符生成倒计时和音乐播放倒计时的差值，单位为毫秒(ms)
var countdown_difference: int

func _ready() -> void:
	set_process(false)
	start_game.connect(_on_start_game)

func _process(delta: float) -> void:
	elasped_time = Time.get_ticks_msec() - cache_start_time

func get_countdown_diff():
	var spawner_countdown_ms: int = note_spawner_timer.wait_time * 1000
	var audio_play_countdown_ms: int = audio_play_timer.wait_time * 1000
	
	countdown_difference = audio_play_countdown_ms - spawner_countdown_ms

func _on_start_game():
	cache_start_time = Time.get_ticks_msec()
	set_process(true)
