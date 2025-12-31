extends RefCounted
class_name RGCParserOM

const HIT_OBJECT_INFO_FORMAT: String = "{\"start_time\":%d, \"end_time\":%d, \"note_type\":\"%s\", \"track\":%d}"
const TIMING_POINT_INFO_FORMAT: String = "{\"time\":%d, \"bpm\":%.2f, \"speed\":%.2f}"

## 解析谱面元数据
func parse_metadata():
	pass

## 解析osu谱面中的 [param TimingPoints] 部分
func parse_timing_points(file_content: String) -> PackedStringArray:
	var results: PackedStringArray
	
	var lines := file_content.strip_edges().split("\n")
	var is_timing_points_section: bool = false
	var first_bpm_beat_length: float = 0.0
	var current_beat_length: float = 0.0
	var current_bpm: float = 0.0
	var cache_time: int = 0
	var cache_speed: float = 1.0
	
	for line: String in lines:
		line = line.strip_edges()
		
		if line == "[TimingPoints]":
			is_timing_points_section = true
			continue
		
		# 如果已经离开HitObjects段落（遇到新的段落开始）
		if is_timing_points_section and line.begins_with("[") and line.ends_with("]"):
			break
		
		if not is_timing_points_section:
			continue
		
		if line.is_empty():
			continue
		
		var parts = line.split(",")
		if parts.size() < 2:
			continue
		
		var time := int(parts[0])
		var value := float(parts[1])
		
		if value > 0:
			# BPM标记
			current_beat_length = value
			current_bpm = 60000.0 / value
			
			if is_zero_approx(first_bpm_beat_length):
				first_bpm_beat_length = current_beat_length
			
			# 添加到结果中
			results.append(TIMING_POINT_INFO_FORMAT % [
				time, 
				current_bpm, 
				current_beat_length / first_bpm_beat_length
			])
			
			cache_time = time
			cache_speed = current_beat_length / first_bpm_beat_length
		
		elif value < 0:
			# 速度标记
			var speed: float = -100.0 / value
			
			# 检查是否已有相同时间的BPM标记
			if cache_time == time:
				# 合并到现有条目
				results.remove_at(results.size() - 1)
				results.append(TIMING_POINT_INFO_FORMAT % [
					time, 
					current_bpm, 
					cache_speed * speed
				])
	
	if results.is_empty():
		push_warning("解析结果为空！文件可能不完整")
	
	return results

## 解析osu谱面中的 [param HitObjects] 部分
func parse_hit_objects(keys: int, file_content: String) -> PackedStringArray:
	var results: PackedStringArray
	
	var lines := file_content.strip_edges().split("\n")
	var in_hitobjects: bool = false
	var line_number: int = 0
	
	for line: String in lines:
		line = line.strip_edges()
		line_number += 1
		
		# 跳过空行和注释
		if line.length() == 0 or line.begins_with("//"):
			continue
		
		# 检测是否进入HitObjects段落
		if line == "[HitObjects]":
			in_hitobjects = true
			continue
		
		# 如果已经离开HitObjects段落（遇到新的段落开始）
		if in_hitobjects and line.begins_with("[") and line.ends_with("]"):
			break
		
		# 处理HitObjects
		if in_hitobjects and line.length() > 0:
			var parts = line.split(",")
			if parts.size() < 3:
				push_warning("行 %d 格式不正确: %s" % [line_number, line])
				continue
			
			# 解析参数
			var x := int(parts[0])
			var start_time := int(parts[2])
			
			# 计算轨道 (使用公式 floor(x * 键位总数 / 512) + 1)
			var track := floori(x * keys / 512.0) + 1
			
			var end_time: int = -1
			var note_type: String = "tap"
			
			# 检查是否有结束时间（第六个参数）
			if parts.size() >= 6:
				var last_part: String = parts[5]
				# 处理可能有冒号分隔的情况
				if ":" in last_part:
					var sub_parts := last_part.split(":")
					if sub_parts.size() > 0 and sub_parts[0].is_valid_int():
						end_time = int(sub_parts[0])
				elif last_part.is_valid_int():
					end_time = int(last_part)
			
			# 确定音符类型
			if end_time > 0:
				note_type = "hold"
			else:
				end_time = -1
			
			# 格式化为输出行: 开始时间,结束时间,音符类型,轨道
			var output_line: String = HIT_OBJECT_INFO_FORMAT % [start_time, end_time, note_type, track]
			results.append(output_line)
	
	if results.is_empty():
		push_warning("解析结果为空！文件可能不完整")
	
	return results

## 根据名称分离每一个小节（解析后的文件）
func split_section(section_name: String, file_content: String) -> PackedStringArray:
	var lines := file_content.split("\n")
	var section_text: String = "[%s]" % section_name
	var in_section: bool = false
	var result: PackedStringArray
	
	for line in lines:
		var trimmed_line := line.strip_edges()
		
		if trimmed_line == section_text:
			in_section = true
			continue
		
		if trimmed_line.begins_with("[") and trimmed_line.ends_with("]"):
			break
		
		if in_section and trimmed_line.length() > 0:
			result.append(trimmed_line) 
	
	return result
