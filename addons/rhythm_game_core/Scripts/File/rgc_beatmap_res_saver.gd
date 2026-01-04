extends ResourceFormatSaver
## 此类属于 RhythmGameCore 插件[br]
## 谱面资源 [RGCBeatmap] 保存器[br]
## [br]
## 这东西总有莫名其妙的BUG，如果遇到不能保存谱面的情况重新加载工程
class_name RGCBeatmapSaver

func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return ["beatmap"]

func _recognize(resource: Resource) -> bool:
	return resource is RGCBeatmap

func _save(resource: Resource, path: String, flags: int) -> Error:
	var beatmap: RGCBeatmap = resource
	if not beatmap:
		return ERR_INVALID_PARAMETER
	
	var timing_point_datas := beatmap.timing_point_datas
	var note_datas := beatmap.note_datas
	var content: String = ""
	
	# 添加时间点段落
	content += "# 时间点信息\n"
	content += "# 格式：time(int), bpm(float), speed(float)\n"
	content += "[TimingPoints]\n"
	for data: Dictionary in timing_point_datas:
		content += "%d, %.2f, %.2f\n" % [
			data["time"],
			data["bpm"],
			data["speed"]
		]
	
	content += "\n"
	
	# 添加音符信息段落
	content += "# 音符信息\n"
	content += "# 格式：start_time(int), end_time(int), note_type(string), track(string)\n"
	content += "[NoteInfos]\n"
	var total_notes: Array = []
	for key: StringName in note_datas.keys():
		var track_notes: Array = note_datas[key]
		total_notes.append_array(track_notes)
	
	total_notes.sort_custom(
		func (a, b):
			return a["start_time"] < b["start_time"]
	)
	
	for dict: Dictionary in total_notes:
		content += "%d, %d, %s, %s\n" % [
			dict["start_time"], 
			dict["end_time"], 
			dict["note_type"], 
			dict["track"]
		]
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		file.get_open_error()
	
	file.store_string(content)
	file.close()
	
	return OK
