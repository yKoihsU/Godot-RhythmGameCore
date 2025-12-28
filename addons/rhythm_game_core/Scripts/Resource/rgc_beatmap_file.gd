extends Resource
class_name RGCBeatmap

## 音符数据，结构为
##[codeblock]
##{ 
##		轨道下标1 = [数据1, 数据2, 数据3...], 
##		轨道下标2... 
##}
##[/codeblock]
@export var note_datas: Dictionary[StringName, Array]

## 时间点数据
@export var timing_point_datas: Array[Dictionary]

## 统计音符数量
func count_note_count(note_type: RGCNoteEvent.NoteType) -> int:
	var note_count: int = 0
	var type_name: String = RGCNoteEvent.type_enum_to_string(note_type).to_lower()
	
	var dict_key := note_datas.keys()
	
	# 统计全部音符
	if type_name == "all":
		for k in dict_key:
			var track_note_datas: Array[Dictionary] = note_datas[k]
			note_count += track_note_datas.size()
		
		return note_count
	
	# 统计特定种类音符
	for k in dict_key:
		var track_note_datas: Array[Dictionary] = note_datas[k]
		for d in track_note_datas:
			if d["note_type"] == type_name:
				note_count += 1
	
	return note_count

## 转换字符串数组为音符数据
func string_array_to_note_datas(array: PackedStringArray):
	if array.is_empty():
		push_error("数组为空！")
		return
	
	for s in array:
		var dict: Dictionary = str_to_var(s)
		
		var track_index: String = str(dict["track"])
		if not note_datas.has(track_index):
			note_datas[track_index] = []
		
		note_datas[track_index].append(dict)

## 转换字符串数组为时间点数据
func string_array_to_timing_point_datas(array: PackedStringArray):
	if array.is_empty():
		push_error("数组为空！")
		return
	
	for s in array:
		var dict: Dictionary = str_to_var(s)
		timing_point_datas.append(dict)
