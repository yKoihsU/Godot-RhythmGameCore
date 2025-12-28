extends Node
class_name RGCTrackManager

## 所有轨道的父节点
@export var track_parent_node: Node

@export var note_pos_calculator: RGCNotePositionCalculator

var note_datas: Dictionary[StringName, Array]
var track_nodes: Array[Node]

func _ready() -> void:
	track_nodes = track_parent_node.get_children()

func convert_data_to_track_event(beatmap_res: RGCBeatmap):
	note_pos_calculator.build_segments(beatmap_res.timing_point_datas)
	
	var track_dict: Dictionary[StringName, RGCNoteTrack]
	for t: RGCNoteTrack in track_nodes:
		track_dict[t.track_index] = t
	
	for key in track_dict:
		if not note_datas.has(key):
			continue
		
		var note_events: Array[RGCNoteEvent] = []
		var track_note: Array[Dictionary] = note_datas[key]
		for n in track_note:
			var type: RGCNoteEvent.NoteType = RGCNoteEvent.string_to_type_enum(n["track"])
			var timeline_pos: float = note_pos_calculator.scroll_to_pos(n["start_time"])
			var spawn_time: int = note_pos_calculator.scroll_to_time(timeline_pos, true)
			
			var event := RGCNoteEvent.new(
				n["start_time"],
				n["end_time"],
				n["track"],
				type,
				spawn_time,
				timeline_pos
			)
			
			note_events.append(event)
		
		track_dict[key].note_events = note_events

func set_track_note_data():
	for track: RGCNoteTrack in track_nodes:
		var track_index: StringName = track.track_index
		if not note_datas.has(track_index):
			push_warning("未找到 track_index 为 %s 的节点" % track_index)
			continue
		
		track.note_events = note_datas[track_index]
