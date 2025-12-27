extends Node
class_name RGCNotePool

## 音符场景集合
@export var note_scene_dict: Dictionary[StringName, PackedScene] = {
	"TapNote" = null,
	"HoldNote" = null
}

## 对象池初始化音符数量
@export var init_note_count: int

var note_pool_dict: Dictionary[StringName, Array] = {
	"TAP": [],
	"HOLD": []
}

func _ready() -> void:
	for i in init_note_count:
		var tap_note := note_scene_dict["TapNote"].instantiate()
		var hold_note := note_scene_dict["HoldNote"].instantiate()
		note_pool_dict["TAP"].append(tap_note)
		note_pool_dict["HOLD"].append(hold_note)

func recycle_note(note_type: RGCNoteEvent.NoteType, note: RGCNoteNode):
	match note_type:
		RGCNoteEvent.NoteType.TAP:
			note_pool_dict["TAP"].append(note)
		RGCNoteEvent.NoteType.HOLD:
			note_pool_dict["HOLD"].append(note)

func get_note_from_pool(note_type: RGCNoteEvent.NoteType) -> RGCNoteNode:
	match note_type:
		RGCNoteEvent.NoteType.TAP:
			var tap_note_pool: Array[RGCNoteNode] = note_pool_dict["TAP"]
			if tap_note_pool.is_empty():
				return note_scene_dict["TAP"].instantiate()
			
			return tap_note_pool.pop_back()
		RGCNoteEvent.NoteType.HOLD:
			var hold_note_pool: Array[RGCNoteNode] = note_pool_dict["HOLD"]
			if hold_note_pool.is_empty():
				return note_scene_dict["HOLD"].instantiate()
			
			return hold_note_pool.pop_back()
	
	push_error("未定义的音符类型！")
	return null
