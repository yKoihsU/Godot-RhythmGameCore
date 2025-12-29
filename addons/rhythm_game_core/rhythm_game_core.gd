@tool
extends EditorPlugin

const OSU_IMPORTER: Resource = preload("res://addons/rhythm_game_core/Scripts/Utility/rgc_osu_file_import.gd")

var osu_importer: EditorImportPlugin
var beatmap_saver: RGCBeatmapSaver
var beatmap_loader: RGCBeatmapLoader

func _init() -> void:
	osu_importer = OSU_IMPORTER.new()
	beatmap_saver = RGCBeatmapSaver.new()
	beatmap_loader = RGCBeatmapLoader.new()

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	add_import_plugin(osu_importer)
	ResourceSaver.add_resource_format_saver(beatmap_saver)
	ResourceLoader.add_resource_format_loader(beatmap_loader)

func _exit_tree() -> void:
	remove_import_plugin(osu_importer)
	ResourceSaver.remove_resource_format_saver(beatmap_saver)
	ResourceLoader.remove_resource_format_loader(beatmap_loader)
