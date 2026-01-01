extends Node
class_name RGCScoreManager

signal add_score(rating: Rating)

var RATING_SCORE_RATIO: Dictionary = {
	"GOOD" = 0.33,
	"GREAT" = 0.66,
	"PERFECT" = 1.00,
	"MARVELOUS" = 1.01
}

enum Rating {
	MISS, 
	GOOD, 
	GREAT, 
	PERFECT, 
	MARVELOUS
}

static var hit_offset: int = 0

static var tap_rating_offset: Dictionary = {
	"MISS" = 999,
	"GOOD" = 100,
	"GREAT" = 75,
	"PERFECT" = 40,
	"MARVELOUS" = 25
}

static var hold_rating_offset: Dictionary = {
	"MISS" = 999,
	"GOOD" = 120,
	"GREAT" = 90,
	"PERFECT" = 50,
	"MARVELOUS" = 35
}

var play_score: int
var combo_count: int = 0
var max_combo_count: int = 0
var accuracy: float = 0.0
var total_note_count: int = 0

var play_rating_count: Dictionary[StringName, int] = {
	"MISS" = 0,
	"GOOD" = 0,
	"GREAT" = 0,
	"PERFECT" = 0,
	"MARVELOUS" = 0
}

func _ready() -> void:
	add_score.connect(_on_add_score)
	
	hit_offset = ProjectSettings.get_setting("RhythmGameCore/hit_offset", 0)

func _on_add_score(rating: Rating):
	match rating:
		Rating.MISS:
			play_rating_count["MISS"] += 1
			combo_count = 0
		Rating.GOOD:
			play_rating_count["GOOD"] += 1
			combo_count += 1
		Rating.GREAT:
			play_rating_count["GREAT"] += 1
			combo_count += 1
		Rating.PERFECT:
			play_rating_count["PERFECT"] += 1
			combo_count += 1
		Rating.MARVELOUS:
			play_rating_count["MARVELOUS"] += 1
			combo_count += 1
	
	max_combo_count = maxi(combo_count, max_combo_count)
	calculate_accuracy()

func set_note_count(value: int):
	total_note_count = value

func calculate_accuracy():
	var good_score: float = play_rating_count["GOOD"] * RATING_SCORE_RATIO["GOOD"]
	var great_score: float = play_rating_count["GREAT"] * RATING_SCORE_RATIO["GREAT"]
	var perfect_score: float = play_rating_count["PERFECT"] * RATING_SCORE_RATIO["PERFECT"]
	var marvelous_score: float = play_rating_count["MARVELOUS"] * RATING_SCORE_RATIO["MARVELOUS"]
	var total_score: float = good_score + great_score + perfect_score +marvelous_score
	
	accuracy = float(total_score) / total_note_count * 100.0

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
