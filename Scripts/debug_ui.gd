extends Control
class_name DebugUI

const TAP_COUNT_TEXT: String = "Tap: %d"
const HOLD_COUNT_TEXT: String = "Hold: %d"
const TOTAL_COUNT_TEXT: String = "Total: %d"
const AUDIO_LENGTH_TEXT: String = "Length: %d : %02d"

const MARVELOUS_COUNT_TEXT: String = "MARVELOUS: %d"
const PERFECT_COUNT_TEXT: String = "PERFECT: %d"
const GREAT_COUNT_TEXT: String = "GREAT: %d"
const GOOD_COUNT_TEXT: String = "GODD: %d"
const MISS_COUNT_TEXT: String = "MISS: %d"
const ACCURACY_TEXT: String = "ACC: %.2f %%"

@export var tap_count: Label
@export var hold_count: Label
@export var total_note_count: Label
@export var audio_length: Label

@export var marvelous_count: Label
@export var perfect_count: Label
@export var great_count: Label
@export var good_count: Label
@export var miss_count: Label
@export var accuracy: Label

func _ready() -> void:
	tap_count.text = TAP_COUNT_TEXT % 0
	hold_count.text = HOLD_COUNT_TEXT % 0
	total_note_count.text = TOTAL_COUNT_TEXT % 0
	audio_length.text = AUDIO_LENGTH_TEXT % [0, 0]
	
	marvelous_count.text = MARVELOUS_COUNT_TEXT % 0
	perfect_count.text = PERFECT_COUNT_TEXT % 0
	great_count.text = GREAT_COUNT_TEXT % 0
	good_count.text = GOOD_COUNT_TEXT % 0
	miss_count.text = MISS_COUNT_TEXT % 0
	accuracy.text = ACCURACY_TEXT % 0.0

func set_audio_length(length: float):
	var seconds: int = int(length) % 60
	var minutes: int = floori(length / 60)
	
	audio_length.text = AUDIO_LENGTH_TEXT % [minutes, seconds]

func set_note_count_data(note_data: RGCBeatmap):
	tap_count.text = TAP_COUNT_TEXT % note_data.count_note_count(RGCNoteEvent.NoteType.TAP)
	hold_count.text = HOLD_COUNT_TEXT % note_data.count_note_count(RGCNoteEvent.NoteType.HOLD)
	total_note_count.text = TOTAL_COUNT_TEXT % note_data.count_note_count(RGCNoteEvent.NoteType.ALL)
