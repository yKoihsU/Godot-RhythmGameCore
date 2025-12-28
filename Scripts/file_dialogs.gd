extends Node

@export var note_pos_calculator: RGCNotePositionCalculator
@export var track_manager: RGCTrackManager

@export var debug_ui: DebugUI

@export var osu_file_dialog: FileDialog
@export var audio_file_dialog: FileDialog

func _on_import_button_pressed() -> void:
	osu_file_dialog.popup_centered()

func _on_osu_file_file_selected(path: String) -> void:
	var parser := RGCParserOM.new()
	
	var start_load_time: int = Time.get_ticks_msec()
	
	var file := FileAccess.open(path, FileAccess.READ)
	var timing_points: PackedStringArray = parser.parse_timing_points(file.get_as_text())
	var hit_objects: PackedStringArray = parser.parse_hit_objects(4, file.get_as_text())
	
	var file_name := path.get_file().get_basename()
	var save_file_path: String = path.get_base_dir().path_join(file_name) + ".tres"
	RGCFileManager.save_parse_file(save_file_path, timing_points, hit_objects)
	
	var beatmap_res: RGCBeatmap = ResourceLoader.load(save_file_path, "RGCBeatmap", ResourceLoader.CACHE_MODE_REPLACE)
	track_manager.note_datas = beatmap_res.note_datas
	track_manager.convert_data_to_track_event(beatmap_res)
	
	print("加载时间：%d ms" % (Time.get_ticks_msec() - start_load_time))
	
	debug_ui.set_note_count_data(beatmap_res)
	
	# audio_file_dialog.popup_centered()
