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
	return "txt"

func _get_resource_type() -> String:
	return "TextFile"

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
	var output_lines: Array[String] = []
	
	var parser := RGCParserOM.new()
	output_lines = parser.parse_hit_objects(keys, source_file)
	
	if output_lines.is_empty():
		return ERR_FILE_CANT_OPEN
	
	# 写入输出文件
	var output_file_path := "%s.%s" % [save_path, _get_save_extension()]
	var output_file := FileAccess.open(output_file_path, FileAccess.WRITE)
	if not output_file:
		return ERR_FILE_CANT_OPEN
	
	# 可选：添加表头
	output_file.store_line("[NoteInfo]")
	
	for line in output_lines:
		output_file.store_line(line)
	
	output_file.close()
	
	return OK
