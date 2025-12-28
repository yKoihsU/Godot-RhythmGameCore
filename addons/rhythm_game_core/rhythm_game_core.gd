@tool
extends EditorPlugin

const OSU_IMPORTER: Resource = preload("res://addons/rhythm_game_core/Scripts/Utility/rgc_file_import.gd") 

var osu_importer: EditorImportPlugin

func _init() -> void:
	osu_importer = OSU_IMPORTER.new()

func _enable_plugin() -> void:
	# Add autoloads here.
	add_import_plugin(osu_importer)
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	remove_import_plugin(osu_importer)
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
