extends Node2D
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

var current_state: States = States.PRESS

var note_type: RGCNoteEvent.NoteType

var note_start_time: int = -1
var start_judge_range: int

var note_end_time: int = -1
var end_judge_range: int

var note_timeline_pos: float

func init_note_event(note_event: RGCNoteEvent) -> void:
	current_state = States.INIT
	note_type = note_event.note_type
	note_start_time = note_event.note_start_time
	note_end_time = note_event.note_end_time
	note_timeline_pos = note_event.note_timeline_pos

func _enter_tree() -> void:
	start_judge_range = RGCScoreManager.get_offset_by_rating(note_type, RGCScoreManager.Rating.GREAT)
	end_judge_range = RGCScoreManager.get_offset_by_rating(note_type, RGCScoreManager.Rating.GOOD)

## 更新位置
func update_position(judge_line_pos: float, elapsed_time_pos_in_timeline: float):
	var pos: float = judge_line_pos - (note_timeline_pos - elapsed_time_pos_in_timeline)
	position.y = pos

## 持续状态判定，部分状态持续一段时间后转为另一个状态
func continuous_state_judge(elasped_time: int):
	match current_state:
		States.INIT:
			if elasped_time >= note_start_time - start_judge_range:
				current_state = States.PRESS
		
		States.PRESS:
			if elasped_time >= note_start_time + end_judge_range:
				var miss_offset: int = RGCScoreManager.get_offset_by_rating(note_type, RGCScoreManager.Rating.MISS)
				RGCScoreManager.get_rating_by_offset(note_type, miss_offset)
				
				match note_type:
					RGCNoteEvent.NoteType.TAP:
						current_state = States.END
					RGCNoteEvent.NoteType.HOLD:
						current_state = States.BREAK
		
		States.BREAK:
			if elasped_time >= note_end_time + end_judge_range:
				var miss_offset: int = RGCScoreManager.get_offset_by_rating(note_type, RGCScoreManager.Rating.MISS)
				RGCScoreManager.get_rating_by_offset(note_type, miss_offset)
				current_state = States.END

## 音符的开头判定，两种音符通用
func note_press_judge(hit_time: int):
	# 在初始化节点时无视判定
	if current_state == States.INIT:
		return
	
	var hit_offset: int = absi(hit_time - note_start_time)
	RGCScoreManager.get_rating_by_offset(note_type, hit_offset)
	match note_type:
		RGCNoteEvent.NoteType.TAP:
			current_state = States.END
		RGCNoteEvent.NoteType.HOLD:
			current_state = States.HOLDING

## 长按音符的结尾判定部分，整体部分较为复杂包装为方法使用
func hold_release_judge(hit_time: int):
	if note_type == RGCNoteEvent.NoteType.TAP:
		return
	
	match current_state:
		States.HOLDING:
			if hit_time >= note_end_time - start_judge_range:
				var hit_offset: int = absi(hit_time - note_end_time)
				RGCScoreManager.get_rating_by_offset(note_type, hit_offset)
				current_state = States.END
				return
			
			current_state = States.BREAK
		
		States.BREAK_HOLDING:
			if hit_time >= note_end_time - start_judge_range:
				var hit_offset: int = end_judge_range
				RGCScoreManager.get_rating_by_offset(note_type, hit_offset)
				current_state = States.END
