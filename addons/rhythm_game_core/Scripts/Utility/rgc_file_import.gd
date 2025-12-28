@tool
extends EditorImportPlugin

# 定义导入参数
const KEYS = 4  # 4键模式

func _get_importer_name() -> String:
	return "osu.mania.importer"

func _get_visible_name() -> String:
	return "osu!mania Importer"

func _get_recognized_extensions() -> PackedStringArray:
	return ["osu"]

func _get_save_extension() -> String:
	return "tres"

func _get_resource_type() -> String:
	return "RGCBeatmap"

func _get_preset_count() -> int:
	return 1

func _get_preset_name(preset_index: int) -> String:
	return "Default"

func _get_import_options(path: String, preset_index: int) -> Array:
	return [
		{
			"name": "keys",
			"default_value": KEYS,
			"property_hint": PROPERTY_HINT_RANGE,
			"hint_string": "1,9,1"
		}
	]

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true

func _import(
		source_file: String, 
		save_path: String, 
		options: Dictionary, 
		platform_variants: Array[String], 
		gen_files: Array[String]
	) -> Error:
	var keys: int = options.get("keys", KEYS)
	
	var file := FileAccess.open(source_file, FileAccess.READ)
	var parser := RGCParserOM.new()
	var timing_points: PackedStringArray = parser.parse_timing_points(file.get_as_text())
	var hit_objects: PackedStringArray = parser.parse_hit_objects(keys, file.get_as_text())
	
	var output_file_path := "%s.%s" % [save_path, _get_save_extension()]
	RGCFileManager.save_parse_file(output_file_path, timing_points, hit_objects)

	return OK
