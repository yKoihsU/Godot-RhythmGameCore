extends Node
class_name RGCTrackManager

## 所有轨道的父节点
@export var track_parent_node: Node

@export var note_pos_calculator: RGCNotePositionCalculator

@export var time_manager: RGCTimeManager

var note_datas: Dictionary[StringName, Array]
var track_nodes: Array[Node]

func _ready() -> void:
	track_nodes = track_parent_node.get_children()
	set_process(false)
	
	time_manager.start_game.connect(_on_start_game)

func _process(delta: float) -> void:
	update_tracks_elasped_time()

func _on_start_game():
	if note_datas.is_empty():
		push_error("音符数据为空！")
		return
	
	set_process(true)
	set_tracks_active_true()

## 激活全部轨道
func set_tracks_active_true():
	for t: RGCNoteTrack in track_nodes:
		t.set_active_true()

## 取消激活全部轨道
func set_tracks_active_false():
	for t: RGCNoteTrack in track_nodes:
		t.set_active_false()

## 更新轨道时间
func update_tracks_elasped_time():
	for t: RGCNoteTrack in track_nodes:
		t.elasped_time = time_manager.elasped_time

## 加载资源文件并转换为音符事件
func convert_data_to_track_event(beatmap_res: RGCBeatmap):
	note_datas = beatmap_res.note_datas
	note_pos_calculator.build_segments(beatmap_res.timing_point_datas)
	
	var track_dict: Dictionary[StringName, RGCNoteTrack]
	for t: RGCNoteTrack in track_nodes:
		track_dict[t.track_index] = t
	
	for key in track_dict:
		if not note_datas.has(key):
			continue
		
		var note_events: Array[RGCNoteEvent] = []
		var track_note: Array = note_datas[key]
		for n: Dictionary in track_note:
			var type: RGCNoteEvent.NoteType = RGCNoteEvent.string_to_type_enum(n["note_type"])
			var timeline_pos_start: float = note_pos_calculator.scroll_to_pos(n["start_time"])
			var spawn_time: int = note_pos_calculator.scroll_to_time(timeline_pos_start, true)
			
			var note_length: float = 0.0
			if type == RGCNoteEvent.NoteType.HOLD:
				var timeline_pos_end: float = note_pos_calculator.scroll_to_pos(n["end_time"])
				note_length = timeline_pos_end - timeline_pos_start
			
			var event := RGCNoteEvent.new(
				n["start_time"],
				n["end_time"],
				str(n["track"]),
				type,
				spawn_time,
				timeline_pos_start, 
				note_length
			)
			
			note_events.append(event)
		
		track_dict[key].note_events = note_events
