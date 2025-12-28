extends Node
class_name RGCFileManager

static func save_parse_file(
	save_file_path: String, 
	timing_points: PackedStringArray, 
	hit_objects: PackedStringArray
	):
	var beatmap_res := RGCBeatmap.new()
	beatmap_res.string_array_to_note_datas(hit_objects)
	beatmap_res.string_array_to_timing_point_datas(timing_points)
	
	var result: Error = ResourceSaver.save(beatmap_res, save_file_path)
	if result == OK:
		print("保存资源文件成功")
		return
	
	push_error("保存失败！错误码：%d" % result)

static func build_time_segments(pos_calculator: RGCNotePositionCalculator, beatmap_file: String):
	var file := FileAccess.open(beatmap_file, FileAccess.READ)
	var parser: RGCParserOM = RGCParserOM.new()
	var time_datas: PackedStringArray = parser.split_section("TimingPoints", file.get_as_text())
	
	pos_calculator.build_segments(time_datas)

static func build_note_objects(pos_calculator: RGCNotePositionCalculator, beatmap_file: String) -> Dictionary:
	if pos_calculator.segments.is_empty():
		push_error("请先使用 build_time_segments() 构建时间分片")
		return {}
	
	var results: Dictionary[StringName, Array]
	
	var file := FileAccess.open(beatmap_file, FileAccess.READ)
	var parser: RGCParserOM = RGCParserOM.new()
	var note_datas: PackedStringArray = parser.split_section("HitObjects", file.get_as_text())
	for n in note_datas:
		var n_dict: Dictionary = str_to_var(n)
		
		var start_time: int = n_dict["start_time"]
		var end_time: int = n_dict["end_time"]
		var note_type := RGCNoteEvent.string_to_type_enum(n_dict["note_type"])
		var track := StringName(n_dict["track"])
		
		var timeline_pos: float = pos_calculator.scroll_to_pos(start_time)
		var spawn_time: int = pos_calculator.scroll_to_time(timeline_pos, true)
		
		var note_event := RGCNoteEvent.new(
			start_time,
			end_time,
			track,
			note_type,
			spawn_time,
			timeline_pos
		)
		
		if not results.has(track):
			results[track] = []
		
		results[track].append(note_event)
	
	return results
