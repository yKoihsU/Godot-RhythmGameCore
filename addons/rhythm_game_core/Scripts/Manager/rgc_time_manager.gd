extends Node
## 此类属于 RhythmGameCore 插件[br]
## 在游玩过程中的主要时间源
class_name RGCTimeManager

signal start_game()

## 音符生成器倒计时
@export var note_spawner_timer: Timer

## 音乐播放倒计时
@export var audio_play_timer: Timer

## 开始时间，单位为毫秒
var cache_start_time: int
## 经过时间，单位为毫秒
var elasped_time: int

## 音乐开始时的延迟，单位为毫秒
var music_offset: int
## AudioServer 延迟，单位为毫秒
var server_offset: int
## 暂停的时间偏移，单位为毫秒
var pause_offset: int

## 暂停时间标记
var cache_pause_time: int

func _ready() -> void:
	set_process(false)
	start_game.connect(_on_start_game)
	
	music_offset = ProjectSettings.get_setting("RhythmGameCore/music_offset", 0)

func _process(delta: float) -> void:
	elasped_time = Time.get_ticks_msec() - cache_start_time - music_offset - server_offset - pause_offset

func reset():
	pause_offset = 0
	server_offset = 0
	cache_start_time = 0
	cache_pause_time = 0
	elasped_time = 0

func pause_game():
	cache_pause_time = Time.get_ticks_msec()

func continue_game():
	pause_offset += Time.get_ticks_msec() - cache_pause_time
	
	var new_server_offset: int = (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()) * 1000.0
	server_offset += new_server_offset

func _on_start_game():
	reset()
	cache_start_time = Time.get_ticks_msec()
	server_offset = (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()) * 1000.0
	set_process(true)
