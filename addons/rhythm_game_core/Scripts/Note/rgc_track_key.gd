extends Button
class_name RGCTrackKey

## 未按下按键时的按键材质
@export var normal_texture: StyleBox

## 按下按键时的按键材质
@export var pressed_texture: StyleBox

## 按键名称Label
@export var key_name: Label

## 键位映射，如果此项为空将设置为轨道按键(需要在轨道节点绑定此节点)
@export var bind_key_mapping: StringName

func _init() -> void:
	toggle_mode = true

func _ready() -> void:
	if normal_texture:
		add_theme_stylebox_override("normal", normal_texture)
	
	if pressed_texture:
		add_theme_stylebox_override("pressed", pressed_texture)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed(bind_key_mapping):
		set_pressed_no_signal(true)
	
	if event.is_action_released(bind_key_mapping):
		set_pressed_no_signal(false)

## 设置按键
func set_key(key_mapping: StringName):
	if bind_key_mapping.is_empty():
		bind_key_mapping = key_mapping
	
	var input_events := InputMap.action_get_events(bind_key_mapping)
	
	if input_events.is_empty():
		push_error("输入事件为空，检查键位 %s 是否设置正确" % bind_key_mapping)
		return
	
	# 设置快捷键(这个不好用，会阻断轨道节点的 _unhandled_key_input() 方法且释放按键时有延迟)
	#var _shortcut := Shortcut.new()
	#_shortcut.events = input_events
	#shortcut = _shortcut
	
	# 设置显示文字
	if not key_name:
		return
	
	var first_event: InputEventKey = input_events[0]
	key_name.text = OS.get_keycode_string(first_event.physical_keycode)
