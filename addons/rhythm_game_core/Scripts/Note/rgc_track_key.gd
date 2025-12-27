extends Button
class_name RGCTrackKey

## 未按下按键时的按键材质
@export var normal_texture: StyleBox = preload("res://addons/rhythm_game_core/Resources/key_normal_texture.tres")

## 按下按键时的按键材质
@export var pressed_texture: StyleBox = preload("res://addons/rhythm_game_core/Resources/key_press_texture.tres")

## 按键名称Label
@export var key_name: Label

func _ready() -> void:
	if normal_texture:
		add_theme_stylebox_override("normal", normal_texture)
	
	if pressed_texture:
		add_theme_stylebox_override("pressed", pressed_texture)

## 设置按键
func set_key(key_mapping: StringName):
	var input_events := InputMap.action_get_events(key_mapping)
	
	# 设置快捷键
	var _shortcut := Shortcut.new()
	_shortcut.events = input_events
	shortcut = _shortcut
	
	# 设置显示文字
	var first_event: InputEventKey = input_events[0]
	key_name.text = OS.get_keycode_string(first_event.physical_keycode)
