extends Node
class_name RGCSettings

const BGM_VOLUME_INFO: Dictionary = {
	"name": "RhythmGameCore/bgm_volume",
	"type": TYPE_INT,
	"hint": PROPERTY_HINT_RANGE,
	"hint_string": "0, 100, 1"
}

const HIT_SOUND_VOLUME_INFO: Dictionary = {
	"name": "RhythmGameCore/hit_sound_volume",
	"type": TYPE_INT,
	"hint": PROPERTY_HINT_RANGE,
	"hint_string": "0, 100, 1"
}

const MUSIC_OFFSET_INFO: Dictionary = {
	"name": "RhythmGameCore/music_offset",
	"type": TYPE_INT,
	"hint": PROPERTY_HINT_RANGE,
	"hint_string": "-500, 500, 1"
}

const HIT_OFFSET_INFO: Dictionary = {
	"name": "RhythmGameCore/hit_offset",
	"type": TYPE_INT,
	"hint": PROPERTY_HINT_RANGE,
	"hint_string": "-500, 500, 1"
}

static func init_setting(setting_name: String, value, info_dict: Dictionary):
	if ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_initial_value(setting_name, value)
		return
	
	ProjectSettings.set_setting(setting_name, value)
	ProjectSettings.add_property_info(info_dict)
	
	ProjectSettings.set_as_basic(setting_name, true)
	ProjectSettings.set_initial_value(setting_name, value)

static func add_project_settings():
	init_setting("RhythmGameCore/bgm_volume", 20, BGM_VOLUME_INFO)
	init_setting("RhythmGameCore/hit_sound_volume", 20, HIT_SOUND_VOLUME_INFO)
	init_setting("RhythmGameCore/music_offset", 0, MUSIC_OFFSET_INFO)
	init_setting("RhythmGameCore/hit_offset", 0, HIT_OFFSET_INFO)
	
	var result := ProjectSettings.save()
	if result == OK:
		print("保存设置成功")
		return
	
	push_error("保存设置失败，错误码: %d" )
