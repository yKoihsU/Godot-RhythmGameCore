extends Node

@export_group("Files")
@export_file("*.osu", "*.beatmap") var beatmap_file: String
@export_file("*.mp3", "*.wav", "*.ogg") var audio_file: String

@export_group("Nodes")
@export var note_pos_calculator: RGCNotePositionCalculator
@export var track_manager: RGCTrackManager

@export var debug_ui: DebugUI

@export var music_player: AudioStreamPlayer

@export var osu_file_dialog: FileDialog
@export var audio_file_dialog: FileDialog

func _ready() -> void:
	_on_audio_file_file_selected(audio_file)

func _on_import_button_pressed() -> void:
	osu_file_dialog.popup_centered()

func _on_osu_file_file_selected(path: String) -> void:
	var start_load_time: int = Time.get_ticks_msec()
	var beatmap_res: RGCBeatmap
	
	if path.get_extension() == "beatmap":
		beatmap_res = ResourceLoader.load(path, "RGCBeatmap", ResourceLoader.CACHE_MODE_REPLACE)
		track_manager.convert_data_to_track_event(beatmap_res)
		RGCSM.set_note_count(beatmap_res.count_note_count(RGCNoteEvent.NoteType.ALL))
		
		print("加载时间: %d ms" % (Time.get_ticks_msec() - start_load_time))
	
		debug_ui.set_note_count_data(beatmap_res)
		audio_file_dialog.popup_centered()
		return
	
	var parser := RGCParserOM.new()
	
	var file := FileAccess.open(path, FileAccess.READ)
	var timing_points: PackedStringArray = parser.parse_timing_points(file.get_as_text())
	var hit_objects: PackedStringArray = parser.parse_hit_objects(4, file.get_as_text())
	
	var file_name := path.get_file().get_basename()
	var save_file_path: String = path.get_base_dir().path_join(file_name) + ".beatmap"
	RGCFileManager.save_parse_file(save_file_path, timing_points, hit_objects)
	
	beatmap_res = ResourceLoader.load(save_file_path, "RGCBeatmap", ResourceLoader.CACHE_MODE_REPLACE)
	track_manager.convert_data_to_track_event(beatmap_res)
	RGCSM.set_note_count(beatmap_res.count_note_count(RGCNoteEvent.NoteType.ALL))
	
	print("加载时间: %d ms" % (Time.get_ticks_msec() - start_load_time))
	
	debug_ui.set_note_count_data(beatmap_res)
	audio_file_dialog.popup_centered()

func _on_audio_file_file_selected(path: String) -> void:
	var start_load_time: int = Time.get_ticks_msec()
	var music_stream: AudioStream = ResourceLoader.load(path, "AudioStream")
	if not music_stream:
		push_error("加载失败！请检查音频是否完整")
		return
	
	music_player.stream = music_stream
	debug_ui.set_audio_length(music_stream.get_length())
	print("加载时间: %d ms" % (Time.get_ticks_msec() - start_load_time))
