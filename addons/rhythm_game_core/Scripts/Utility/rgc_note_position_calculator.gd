extends Node
class_name RGCNotePositionCalculator

const MAX_INT: int = 2147483647

## 单位为 像素/秒 (pixel/s)
@export var BASE_SPEED: float

## 音符生成的位置到视窗底部距离（视窗高度为720px，放大缩小视窗都不影响）
@export var SPAWN_DISTANCE: float

var segments: Array[Segment]
var seg_pos_index: int
var seg_time_index: int
var seg_elasped_time_index: int

class Segment:
	var start_time: int ## 单位为毫秒(ms)
	var end_time: int ## 单位为毫秒(ms)
	var speed: float
	var cumulative: float
	var cumulative_end: float
	
	func calculate_cumulative_end(base_speed: float) -> float:
		cumulative_end = cumulative + base_speed * speed * (end_time - start_time) / 1000.0
		return cumulative_end

## 建立时间切片组
func build_segments(time_datas: Array[Dictionary]):
	var cumulative_position: float = 0.0
	
	if time_datas.size() == 1:
		var t_dict: Dictionary = time_datas[0]
		
		var seg: Segment = Segment.new()
		seg.start_time = t_dict["start_time"]
		seg.end_time = MAX_INT
		seg.speed = t_dict["speed"]
		seg.cumulative = 0.0
		seg.cumulative_end = MAX_INT
		
		segments.append(seg)
		return
	
	for i in range(1, time_datas.size()):
		var t_dict: Dictionary = time_datas[i-1]
		var next_t_dict: Dictionary = time_datas[i]
		
		var seg: Segment = Segment.new()
		seg.start_time = t_dict["start_time"]
		seg.end_time = next_t_dict["start_time"]
		seg.speed = t_dict["speed"]
		
		seg.cumulative = cumulative_position
		if seg.end_time == MAX_INT:
			seg.cumulative_end = MAX_INT
			continue
		
		cumulative_position = seg.calculate_cumulative_end(BASE_SPEED)
		segments.append(seg)
	
	var final_seg: Segment = Segment.new()
	if segments.is_empty():
		final_seg.start_time = 0
		final_seg.end_time = MAX_INT
		final_seg.speed = 1.0
		final_seg.cumulative = 0
		final_seg.cumulative_end = MAX_INT
		
		segments.append(final_seg)
		return
	
	final_seg.start_time = segments[segments.size() - 1].end_time
	final_seg.end_time = MAX_INT
	final_seg.speed = segments[segments.size() - 1].speed
	final_seg.cumulative = segments[segments.size() - 1].cumulative_end
	final_seg.cumulative_end = MAX_INT
	
	segments.append(final_seg)

## 重置下标
func reset_index():
	seg_pos_index = 0
	seg_time_index = 0

## 辅助方法，把时间轴中的时间转为音符位置
func scroll_to_pos(time: int) -> float:
	if segments.is_empty():
		return BASE_SPEED * time / 1000.0
	
	seg_pos_index = clampi(seg_pos_index, 0, segments.size() - 1)
	
	var seg: Segment = segments[seg_pos_index]
	# 当 time 正好在目前 seg 的 end_time 前
	if time >= seg.start_time and time < seg.end_time:
		return seg.cumulative + BASE_SPEED * seg.speed * (time - seg.start_time) / 1000.0
	
	# 当 time 在目前 seg 的 end_time 之后
	if time >= seg.end_time:
		for i in range(seg_pos_index + 1, segments.size()):
			seg = segments[i]
			if time >= seg.start_time and time < seg.end_time:
				seg_pos_index = i
				return seg.cumulative + BASE_SPEED * seg.speed * (time - seg.start_time) / 1000.0
		
		var last_seg: Segment = segments[-1]
		seg_pos_index = segments.size() - 1
		return last_seg.cumulative + BASE_SPEED * last_seg.speed * (time - last_seg.start_time) / 1000.0
	
	# 当 time 在目前 seg 的 start_time 之前
	for i in range(seg_pos_index - 1, -1, -1):
		seg = segments[i]
		if time >= seg.start_time and time < seg.end_time:
			seg_pos_index = i
			return seg.cumulative + BASE_SPEED * seg.speed * (time - seg.start_time) / 1000.0
	
	# 保险情况下的二分查找
	var l = 0
	var r = segments.size() - 1
	while l <= r:
		var m = (l + r) >> 1
		seg = segments[m]
		if time >= seg.start_time and time < seg.end_time:
			seg_pos_index = m
			return seg.cumulative + BASE_SPEED * seg.speed * (time - seg.start_time) / 1000.0
		elif time < seg.start_time:
			r = m - 1
		else:
			l = m + 1
	
	var last_seg: Segment = segments[-1]
	seg_pos_index = segments.size() - 1
	return last_seg.cumulative + BASE_SPEED * last_seg.speed * (time - last_seg.start_time) / 1000.0

## 辅助方法，把时间轴音符位置转为时间
func scroll_to_time(scroll_value: float, use_spawn_distance: bool) -> int:
	if use_spawn_distance:
		scroll_value -= SPAWN_DISTANCE
	
	if segments.is_empty():
		return scroll_value / BASE_SPEED * 1000.0
	
	clampi(seg_time_index, 0, segments.size() - 1)
	
	var seg: Segment = segments[seg_time_index]
	var seg_end: float = seg.cumulative_end
	
	# 当 scroll_value 在 seg的cumulative区间 内
	if scroll_value >= seg.cumulative and (seg_end == INF or scroll_value < seg_end):
		return seg.start_time + (scroll_value - seg.cumulative) / (BASE_SPEED * seg.speed) * 1000.0
	
	# 当 scroll_value 超过 seg的cumulative区间
	if scroll_value >= seg_end:
		for i in range(seg_time_index + 1, segments.size()):
			seg = segments[seg_time_index]
			seg_end = seg.cumulative_end
			if scroll_value >= seg.cumulative and (seg_end == INF or scroll_value < seg_end):
				return seg.start_time + (scroll_value - seg.cumulative) / (BASE_SPEED * seg.speed) * 1000.0
		
		var last_seg: Segment = segments[-1]
		seg_time_index = segments.size() - 1
		return last_seg.start_time + (scroll_value - last_seg.cumulative) / (BASE_SPEED * last_seg.speed) * 1000.0
	
	# 当 scroll_value 在 seg的cumulative区间 之前
	for i in range(seg_time_index - 1, -1, -1):
		seg = segments[seg_time_index]
		seg_end = seg.cumulative_end
		if scroll_value >= seg.cumulative and (seg_end == INF or scroll_value < seg_end):
			return seg.start_time + (scroll_value - seg.cumulative) / (BASE_SPEED * seg.speed) * 1000.0
	
	# 保险情况下二分查找
	var l: int = 0
	var r: int = segments.size() - 1
	while l <= r:
		var m: int = (l + r) >> 1
		seg = segments[m]
		seg_end = seg.cumulative_end
		if scroll_value >= seg.cumulative and scroll_value < seg.cumulative_end:
			seg_time_index = m
			return seg.start_time + (scroll_value - seg.cumulative) / (BASE_SPEED * seg.speed) * 1000.0
		elif scroll_value < seg.cumulative:
			r = m - 1
		else:
			l = m + 1
	
	var last_seg: Segment = segments[-1]
	seg_time_index = segments.size() - 1
	return last_seg.start_time + (scroll_value - last_seg.cumulative) / (BASE_SPEED * last_seg.speed) * 1000.0

## 将经过的时间转化为音符位置，根据时间正向流动的特点做了优化
func elasped_time_to_pos(time: int) -> float:
	var current_seg: Segment = segments[seg_elasped_time_index]
	if time > current_seg.end_time and seg_elasped_time_index != segments.size() - 1:
		seg_elasped_time_index += 1
		seg_elasped_time_index = clampi(seg_elasped_time_index, 0, segments.size() - 1)
		current_seg = segments[seg_elasped_time_index]
	
	return current_seg.cumulative + BASE_SPEED * current_seg.speed * (time - current_seg.start_time) / 1000.0

## 计算音符生成时间（起始时间为 [param 0] 以下的音符会被转化为 [param 0]）
#func calculate_note_spawn_time(note_type: RGCNoteEvent.NoteType, note_time_arr: Array) -> PackedInt32Array:
	#var note_spawn_times: PackedInt32Array
	#
	#if note_type == RGCNoteEvent.NoteType.TAP:
		#for t in note_time_arr:
			#var note_scroll: float = scroll_to_pos(t) - SPAWN_DISTANCE
			#var spawn_time_ms: int = scroll_to_time(note_scroll)
			#spawn_time_ms = clampi(spawn_time_ms, 0, MAX_INT)
			#
			#note_spawn_times.append(spawn_time_ms)
	#
	#elif note_type == RGCNoteEvent.NoteType.HOLD:
		#for t_arr in note_time_arr:
			#var note_scroll: float = scroll_to_pos(t_arr[0]) - SPAWN_DISTANCE
			#var spawn_time_ms: int = scroll_to_time(note_scroll)
			#spawn_time_ms = clampi(spawn_time_ms, 0, MAX_INT)
			#
			#note_spawn_times.append(spawn_time_ms)
	#
	#reset_index()
	#return note_spawn_times.duplicate()
