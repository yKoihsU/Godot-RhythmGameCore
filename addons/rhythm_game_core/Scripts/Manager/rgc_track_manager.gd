extends Node
class_name RGCTrackManager

## 所有轨道的父节点
@export var track_parent_node: Node

var note_datas: Dictionary[StringName, Array]
var track_nodes: Array[Node]

func _ready() -> void:
	track_nodes = track_parent_node.get_children()

func set_track_note_data():
	for track: RGCNoteTrack in track_nodes:
		var track_index: StringName = track.track_index
		if not note_datas.has(track_index):
			push_warning("未找到 track_index 为 %s 的节点" % track_index)
			continue
		
		track.note_events = note_datas[track_index]
