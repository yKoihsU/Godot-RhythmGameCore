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

const BGM_BUS_INFO: Dictionary = {
	"name": "RhythmGameCore/bgm_bus_name",
	"type": TYPE_STRING_NAME,
	"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
	"hint_string": "BGM"
}

const HIT_SOUND_BUS_INFO: Dictionary = {
	"name": "RhythmGameCore/hit_sound_bus_name",
	"type": TYPE_STRING_NAME,
	"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
	"hint_string": "SFX"
}

static func init_setting(setting_name: String, value, info_dict: Dictionary):
	if ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_initial_value(setting_name, value)
		return
	
	ProjectSettings.set_setting(setting_name, value)
	ProjectSettings.add_property_info(info_dict)
	
	ProjectSettings.set_as_basic(setting_name, true)
	ProjectSettings.set_initial_value(setting_name, value)

static func set_audio_settings():
	var bgm_bus_name: StringName = ProjectSettings.get_setting("RhythmGameCore/bgm_bus_name", "")
	var sfx_bus_name: StringName = ProjectSettings.get_setting("RhythmGameCore/hit_sound_bus_name", "")
	
	if not bgm_bus_name.is_empty():
		var bgm_bus_id := AudioServer.get_bus_index(bgm_bus_name)
		if bgm_bus_id == -1:
			push_error("找不到对应名称的 BGM 音频总线！")
			return
		
		var bgm_volume := ProjectSettings.get_setting("RhythmGameCore/bgm_volume", 12)
		AudioServer.set_bus_volume_linear(bgm_bus_id, float(bgm_volume) / 100.0)
	
	if not sfx_bus_name.is_empty():
		var sfx_bus_id := AudioServer.get_bus_index(sfx_bus_name)
		if sfx_bus_id == -1:
			push_error("找不到对应名称的 SFX 音频总线！")
			return
		
		var sfx_volume := ProjectSettings.get_setting("RhythmGameCore/hit_sound_volume", 12)
		AudioServer.set_bus_volume_linear(sfx_bus_id, float(sfx_volume) / 100.0)

static func add_project_settings():
	init_setting("RhythmGameCore/bgm_volume", 20, BGM_VOLUME_INFO)
	init_setting("RhythmGameCore/hit_sound_volume", 20, HIT_SOUND_VOLUME_INFO)
	init_setting("RhythmGameCore/music_offset", 0, MUSIC_OFFSET_INFO)
	init_setting("RhythmGameCore/hit_offset", 0, HIT_OFFSET_INFO)
	init_setting("RhythmGameCore/bgm_bus_name", &"BGM", BGM_BUS_INFO)
	init_setting("RhythmGameCore/hit_sound_bus_name", &"SFX", HIT_SOUND_BUS_INFO)
	
	var result := ProjectSettings.save()
	if result == OK:
		print("保存设置成功")
		return
	
	push_error("保存设置失败，错误码: %d" )
