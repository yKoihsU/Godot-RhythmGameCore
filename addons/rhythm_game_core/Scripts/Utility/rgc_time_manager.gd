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

func _ready() -> void:
	set_process(false)
	start_game.connect(_on_start_game)
	
	music_offset = ProjectSettings.get_setting("RhythmGameCore/music_offset", 0)

func _process(delta: float) -> void:
	elasped_time = Time.get_ticks_msec() - cache_start_time - music_offset

func _on_start_game():
	cache_start_time = Time.get_ticks_msec()
	set_process(true)
