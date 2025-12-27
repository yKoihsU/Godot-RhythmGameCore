@tool
extends EditorPlugin

const OSU_IMPORTER: Resource = preload("res://addons/rhythm_game_core/Scripts/Utility/rgc_file_import.gd") 

func _enable_plugin() -> void:
	# Add autoloads here.
	# add_import_plugin(OSU_IMPORTER.new())
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
