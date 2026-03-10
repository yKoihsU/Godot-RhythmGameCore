extends Node2D
## 此类属于 RhythmGameCore 插件[br]
## 音符节点，此节点下可放置 [Control] 类节点实现视觉
class_name RGCNoteNode

enum States {
	INIT, ## 初始化
	PRESS, ## 开始按下音符
	END, ## 结束按下音符
	HOLDING, ## 正在按下音符(仅长按音符)
	BREAK, ## 按下音符中断(仅长按音符)
	BREAK_HOLDING, ## 中断后按下音符(仅长按音符)
	AUTO, ## 自动
}

## 音符默认长度
@export var note_default_length: float = 40.0

## 音符材质
@export var note_texture: TextureRect = null

## 音符着色器（Tap 类音符不需要设置此项）
@export var note_shader: Shader = null

## 音符状态颜色组
@export var color_group: Dictionary[StringName, Color] = {
	"OriginColor" = Color(1.0, 1.0, 1.0, 1.0),
	"MissingColor" = Color(0.746, 0.746, 0.746, 1.0)
}

## 目前的音符状态
var current_state: States = States.PRESS

## 音符类型
var note_type: RGCNoteEvent.NoteType = RGCNoteEvent.NoteType.TAP

## 音符头判定时间
var note_start_time: int = -1
## 音符头判定偏差
var start_judge_range: int = 0

## 音符尾判定时间（在 [param Hold] 类音符中使用）
var note_end_time: int = -1
## 音符尾判定偏差（在 [param Hold] 类音符中使用）
var end_judge_range: int = 0

## 音符在时间轴上的位置
var note_timeline_pos: float = 0.0

## 仅在 [param Hold] 类音符中使用
var note_length: float = 0.0

## 音符的 [Shader] 材质
var note_material: Material = null

## 初始化参数
func init_note_event(note_event: RGCNoteEvent) -> void:
	current_state = States.INIT
	note_type = note_event.note_type
	note_start_time = note_event.note_start_time
	note_end_time = note_event.note_end_time
	note_timeline_pos = note_event.note_timeline_pos
	note_length = note_event.note_length

## 初始化材质
func init_texture(texture_dict: Dictionary) -> void:
	match note_type:
		RGCNoteEvent.NoteType.TAP:
			note_texture.texture = texture_dict["TapNote"]
		
		RGCNoteEvent.NoteType.HOLD:
			note_texture.texture = texture_dict["HoldNote"]

## 初始化着色器
func init_shader() -> void:
	if not note_shader:
		return
	
	note_material = ShaderMaterial.new()
	note_material.shader = note_shader
	note_texture.material = note_material

## 设置长度
func set_note_length() -> void:
	if is_zero_approx(note_length):
		return
	
	if not note_texture:
		push_warning("无音符材质，跳过长度设置")
		return
	
	note_texture.size.y = note_length

func _enter_tree() -> void:
	start_judge_range = RGCScoreManager.get_offset_by_rating(note_type, RGCScoreManager.Rating.GREAT)
	end_judge_range = RGCScoreManager.get_offset_by_rating(note_type, RGCScoreManager.Rating.GOOD)

## 重置音符信息
func reset_info() -> void:
	current_state = States.INIT
	note_type = RGCNoteEvent.NoteType.TAP
	note_start_time = -1
	note_end_time = -1
	note_timeline_pos = 0.0
	note_texture.size.y = note_default_length

## 更新位置
func update_position(judge_line_pos: float, elapsed_time_pos_in_timeline: float) -> void:
	var pos: float = judge_line_pos - (note_timeline_pos - elapsed_time_pos_in_timeline)
	position.y = pos

## 持续状态判定，部分状态持续一段时间后转为另一个状态(主要在hold类音符中使用)，返回结果为hold是否到达结尾
func continuous_state_judge(elasped_time: int) -> bool:
	match current_state:
		States.INIT:
			if elasped_time >= note_start_time - start_judge_range:
				current_state = States.PRESS
		
		States.PRESS:
			if elasped_time >= note_start_time + end_judge_range:
				RGCSM.add_score.emit(RGCScoreManager.Rating.MISS)
				
				match note_type:
					RGCNoteEvent.NoteType.TAP: 
						current_state = States.END
					RGCNoteEvent.NoteType.HOLD:
						current_state = States.BREAK
		
		States.HOLDING:
			if elasped_time >= note_end_time:
				RGCSM.add_score.emit(RGCScoreManager.Rating.MARVELOUS)
				current_state = States.END
				return true
		
		States.BREAK_HOLDING:
			if elasped_time >= note_end_time:
				RGCSM.add_score.emit(RGCScoreManager.Rating.GOOD)
				current_state = States.END
				return true
		
		States.BREAK:
			note_material.set_shader_parameter(&"base_color", color_group["MissingColor"])
			if elasped_time >= note_end_time + end_judge_range:
				RGCSM.add_score.emit(RGCScoreManager.Rating.MISS)
				current_state = States.END
				return false
	
	return false

## 音符的开头判定，两种音符通用，返回的结果为是否判定成功
func note_press_judge(hit_time: int) -> bool:
	# 在初始化节点时无视判定
	if current_state == States.INIT:
		return false
	
	var hit_offset: int = absi(hit_time - note_start_time + RGCScoreManager.hit_offset)
	var rating: RGCScoreManager.Rating = RGCScoreManager.get_rating_by_offset(note_type, hit_offset)
	RGCSM.add_score.emit(rating)
	
	match note_type:
		RGCNoteEvent.NoteType.TAP:
			current_state = States.END
			return true
		RGCNoteEvent.NoteType.HOLD:
			if current_state == States.BREAK:
				note_material.set_shader_parameter(&"base_color", color_group["OriginColor"])
				current_state = States.BREAK_HOLDING
				return false
			
			current_state = States.HOLDING
			return true
	
	return false

## 长按音符的结尾判定部分，整体部分较为复杂包装为方法使用，返回的结果为是否判定成功
func hold_release_judge(hit_time: int) -> bool:
	if note_type == RGCNoteEvent.NoteType.TAP:
		return false
	
	match current_state:
		States.HOLDING:
			if hit_time >= note_end_time - start_judge_range:
				RGCSM.add_score.emit(RGCScoreManager.Rating.MARVELOUS)
				current_state = States.END
				return true
			
			current_state = States.BREAK
			return false
		
		States.BREAK_HOLDING:
			if hit_time >= note_end_time - start_judge_range:
				RGCSM.add_score.emit(RGCScoreManager.Rating.GOOD)
				current_state = States.END
				return true
	
	return false
