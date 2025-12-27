extends Node
class_name RGCScoreManager

signal add_score(rating: Rating)

enum Rating {
	MISS, 
	GOOD, 
	GREAT, 
	PERFECT, 
	MARVELOUS
}

static var tap_rating_offset: Dictionary = {
	"MISS" = 120,
	"GOOD" = 100,
	"GREAT" = 75,
	"PERFECT" = 40,
	"MARVELOUS" = 25
}

static var hold_rating_offset: Dictionary = {
	"MISS" = 150,
	"GOOD" = 120,
	"GREAT" = 90,
	"PERFECT" = 50,
	"MARVELOUS" = 35
}

var play_score: int
var play_rating_count: Dictionary = {
	"MISS" = 0,
	"GOOD" = 0,
	"GREAT" = 0,
	"PERFECT" = 0,
	"MARVELOUS" = 0
}

## 将枚举转换为评级的偏差，例如 [param Rating.GREAT] 将转换为 [param 75] (单点类型的音符)
static func get_offset_by_rating(note_type: RGCNoteEvent.NoteType, rating: Rating) -> int:
	var rating_name: String = Rating.find_key(rating)
	
	if note_type == RGCNoteEvent.NoteType.TAP:
		return tap_rating_offset[rating_name]
	
	elif note_type == RGCNoteEvent.NoteType.HOLD:
		return hold_rating_offset[rating_name]
	
	push_error("未定义的音符类型！")
	return 0

## 将打击偏差转换为评级
static func get_rating_by_offset(note_type: RGCNoteEvent.NoteType, hit_offset: int) -> Rating:
	if note_type == RGCNoteEvent.NoteType.TAP:
		if hit_offset <= tap_rating_offset["MARVELOUS"]:
			return Rating.MARVELOUS
		elif hit_offset <= tap_rating_offset["PERFECT"]:
			return Rating.PERFECT
		elif hit_offset <= tap_rating_offset["GREAT"]:
			return Rating.GREAT
		elif hit_offset <= tap_rating_offset["GOOD"]:
			return Rating.GOOD
		else :
			return Rating.MISS
	
	elif note_type == RGCNoteEvent.NoteType.HOLD:
		if hit_offset <= hold_rating_offset["MARVELOUS"]:
			return Rating.MARVELOUS
		elif hit_offset <= hold_rating_offset["PERFECT"]:
			return Rating.PERFECT
		elif hit_offset <= hold_rating_offset["GREAT"]:
			return Rating.GREAT
		elif hit_offset <= hold_rating_offset["GOOD"]:
			return Rating.GOOD
		else :
			return Rating.MISS
	
	return Rating.MISS
