extends Control
class_name RGCNoteTrack

## 音符场景集合
@export var note_scene_dict: Dictionary[StringName, PackedScene] = {
	"TapNote" = null,
	"HoldNote" = null
}

@export var note_texture_dict: Dictionary[StringName, Texture2D] = {
	"TapNote" = null,
	"HoldNote" = null
}

## 轨道唯一ID
@export var track_index: StringName

## 轨道绑定的键位映射（项目设置/输入映射 中的按键映射名称）
@export var bind_key_mapping: StringName

## 按键节点
@export var bind_key_node: RGCTrackKey

## 打击特效节点
@export var hit_effect_node: AnimatedSprite2D

## 打击音效节点
@export var hit_sound_node: AudioStreamPlayer

## 判定线位置（[param position] 中的 [param y]）
@export var judge_line_position: float

## 音符位置计算器
@export var note_pos_calculator: RGCNotePositionCalculator

## 音符对象池
@export var note_pool: RGCNotePool

## 经过的时间
var elasped_time: int
var elasped_time_pos_in_timeline: float

## 现在击打的音符
var current_hit_note: RGCNoteNode

## 音符事件组
var note_events: Array[RGCNoteEvent]
var current_event: RGCNoteEvent
var current_event_index: int = 0

func _ready() -> void:
	set_active_false()
	set_bind_key()

func _process(_delta: float) -> void:
	generate_note_node()
	update_all_notes_position()
	find_the_nearest_note()
	update_current_hit_note_state()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed(bind_key_mapping) and current_hit_note:
		if current_hit_note.note_press_judge(elasped_time):
			play_hit_effect()
			play_hit_sound()
	
	if event.is_action_released(bind_key_mapping) and current_hit_note:
		if current_hit_note.hold_release_judge(elasped_time):
			play_hit_effect()
			play_hit_sound()

## 播放打击音效
func play_hit_sound():
	if not hit_sound_node:
		return
	
	if hit_sound_node.playing:
		hit_sound_node.stop()
	
	hit_sound_node.play()

## 播放打击特效
func play_hit_effect():
	if not hit_effect_node:
		return
	
	if hit_effect_node.is_playing():
		hit_effect_node.stop()
		
	hit_effect_node.play(&"Hit")

## 激活轨道
func set_active_true():
	set_process(true)
	set_process_unhandled_key_input(true)

## 取消激活轨道
func set_active_false():
	set_process(false)
	set_process_unhandled_key_input(false)

## 设置按键（如果有的话）
func set_bind_key():
	if bind_key_mapping and bind_key_node:
		bind_key_node.set_key(bind_key_mapping)

## 生成音符节点
func generate_note_node():
	if current_event_index >= note_events.size():
		return
	
	current_event = note_events[current_event_index]
	if elasped_time_pos_in_timeline + judge_line_position >= current_event.note_timeline_pos:
		var note: RGCNoteNode = note_pool.get_note_from_pool(current_event.note_type)
		note.init_note_event(current_event)
		note.init_texture(note_texture_dict)
		note.init_shader()
		note.set_note_length()
		note.name = "%s%d" % [RGCNoteEvent.type_enum_to_string(current_event.note_type), current_event_index]
		add_child(note)
		current_event_index += 1

## 更新轨道节点下所有音符节点的位置
func update_all_notes_position():
	elasped_time_pos_in_timeline = note_pos_calculator.elasped_time_to_pos(elasped_time)
	
	var notes := get_children()
	if notes.is_empty():
		return
	
	for n: RGCNoteNode in notes:
		n.update_position(judge_line_position, elasped_time_pos_in_timeline)

## 寻找距离经过时间最近的音符
func find_the_nearest_note():
	var notes := get_children()
	if notes.is_empty():
		return
	
	notes.sort_custom(
		func(a: RGCNoteNode, b: RGCNoteNode):
			return a.note_start_time < b.note_start_time
	)
	
	current_hit_note = notes[0]

## 更新目前捕捉音符的状态
func update_current_hit_note_state():
	if not current_hit_note:
		return
	
	if current_hit_note.continuous_state_judge(elasped_time):
		play_hit_effect()
		play_hit_sound()
	
	if current_hit_note.current_state == RGCNoteNode.States.END:
		recycle_hit_note()

## 回收击打音符到对象池中
func recycle_hit_note():
	note_pool.recycle_note(
		current_hit_note.note_type, 
		current_hit_note
	)
	
	remove_child(current_hit_note)
	current_hit_note.reset_info()
	current_hit_note = null
