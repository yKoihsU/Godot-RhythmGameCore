extends ResourceFormatLoader
## 此类属于 RhythmGameCore 插件[br]
## 谱面资源 [RGCBeatmap] 解析器[br]
## [br]
## 这东西总有莫名其妙的BUG，如果遇到不能加载谱面的情况重新加载工程
class_name RGCBeatmapLoader

func _handles_type(type: StringName) -> bool:
	return type == &"RGCBeatmap" or ClassDB.is_parent_class(type, &"Resource")

func _get_resource_type(path: String) -> String:
	return "RGCBeatmap"

func _get_recognized_extensions() -> PackedStringArray:
	return ["beatmap"]

func _get_dependencies(path: String, add_types: bool) -> PackedStringArray:
	return [
		"res://addons/rhythm_game_core/Scripts/Resource/rgc_beatmap_file.gd"
	]

func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
	
	var beatmap := RGCBeatmap.new()
	
	var file := FileAccess.open(path, FileAccess.READ)
	var content: PackedStringArray = file.get_as_text().split("\n")
	
	var in_timing_points_section: bool = false
	var in_note_infos_section: bool = false
	for line in content:
		if line.is_empty():
			continue
		
		if line.begins_with("#"):
			continue
		
		if line.begins_with("[") and line.ends_with("]"):
			in_timing_points_section = false
			in_note_infos_section = false
		
		if line == "[TimingPoints]":
			in_timing_points_section = true
			continue
		
		if line == "[NoteInfos]":
			in_note_infos_section = true
			continue
		
		if in_timing_points_section:
			var time_data := line.split(", ", false)
			var dict: Dictionary = {
				"time": int(time_data[0]),
				"bpm": float(time_data[1]),
				"speed": float(time_data[2])
			}
			
			beatmap.timing_point_datas.append(dict)
			continue
		
		if in_note_infos_section:
			var note_data := line.split(", ", false)
			var dict: Dictionary = {
				"start_time": int(note_data[0]),
				"end_time": int(note_data[1]),
				"note_type": note_data[2],
				"track": note_data[3]
			}
			
			if not beatmap.note_datas.has(note_data[3]):
				beatmap.note_datas[note_data[3]] = []
			beatmap.note_datas[note_data[3]].append(dict)
			continue
	
	return beatmap
