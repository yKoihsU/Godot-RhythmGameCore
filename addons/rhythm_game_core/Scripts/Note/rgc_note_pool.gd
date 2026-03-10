extends Node
## 此类属于 RhythmGameCore 插件[br]
## 音符对象池，用于缓存音符节点节省性能
class_name RGCNotePool

## 音符场景集合
@export var note_scene_dict: Dictionary[StringName, PackedScene] = {
	"TapNote" = null,
	"HoldNote" = null
}

## 对象池初始化音符数量
@export var init_note_count: int

## 对象池集合
var note_pool_dict: Dictionary[StringName, Array] = {
	"TAP": [],
	"HOLD": []
}

func _ready() -> void:
	for i in init_note_count:
		var tap_note: RGCNoteNode = note_scene_dict["TapNote"].instantiate()
		var hold_note: RGCNoteNode = note_scene_dict["HoldNote"].instantiate()
		note_pool_dict["TAP"].append(tap_note)
		note_pool_dict["HOLD"].append(hold_note)

## 回收音符
func recycle_note(note_type: RGCNoteEvent.NoteType, note: RGCNoteNode):
	match note_type:
		RGCNoteEvent.NoteType.TAP:
			note_pool_dict["TAP"].append(note)
		RGCNoteEvent.NoteType.HOLD:
			note_pool_dict["HOLD"].append(note)

## 从对象池中获取音符
func get_note_from_pool(note_type: RGCNoteEvent.NoteType) -> RGCNoteNode:
	match note_type:
		RGCNoteEvent.NoteType.TAP:
			var tap_note_pool: Array = note_pool_dict["TAP"]
			if tap_note_pool.is_empty():
				return note_scene_dict["TapNote"].instantiate()
			
			return tap_note_pool.pop_back()
		RGCNoteEvent.NoteType.HOLD:
			var hold_note_pool: Array = note_pool_dict["HOLD"]
			if hold_note_pool.is_empty():
				return note_scene_dict["HoldNote"].instantiate()
			
			return hold_note_pool.pop_back()
	
	push_error("未定义的音符类型！")
	return null
