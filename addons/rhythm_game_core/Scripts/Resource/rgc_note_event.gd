extends RefCounted
class_name RGCNoteEvent

const OUTPUT_INFO: String = "start_time:%d, end_time:%d, note_type:%s, track:%s"

enum NoteType {
	TAP, ## 单点，仅有 “打击" 一个状态
	HOLD, ## 长按， 除了基础状态还有 "正在按下", “中断”, "中断后按下" 三个额外状态
	ALL ## 全音符，仅用于数据统计
}

## 音符的起始时间，单位为毫秒(ms)
@export var note_start_time: int = -1

## 音符的结束时间，单位为毫秒(ms)，仅在长条类音符中使用
@export var note_end_time: int = -1

## 音符种类
@export var note_type: NoteType

## 音符下落使用的轨道，使用字符串进行标记
@export var note_track_index: StringName

## 音符生成时间，单位为毫秒(ms)，不储存在文件中，在加载时计算
@export var note_spawn_time: int = -1

## 音符在时间轴上的位置，单位为像素(px)，不储存在文件中，在加载时计算
@export var note_timeline_pos: float = 0.0

## 音符长度，仅在Hold类音符使用
@export var note_length: float = 0.0

func _init(start_time: int, 
		end_time: int, 
		track_index: StringName, 
		type: NoteType, 
		spawn_time: int, 
		timeline_pos: float, 
		length: float
	) -> void:
	note_start_time = start_time
	note_end_time = end_time
	note_track_index = track_index
	note_type = type
	note_spawn_time = spawn_time
	note_timeline_pos = timeline_pos
	note_length = length

func _to_string() -> String:
	var note_type_name: String = NoteType.find_key(note_type)
	return OUTPUT_INFO % [note_start_time, note_end_time, note_type_name, note_track_index]

static func type_enum_to_string(type: NoteType) -> String:
	return NoteType.find_key(type)

static func string_to_type_enum(key_name: String) -> NoteType:
	return NoteType.get(key_name.to_upper(), NoteType.TAP)
