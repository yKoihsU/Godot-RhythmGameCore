extends Control
class_name DebugUI

const TAP_COUNT_TEXT: String = "Tap: %d"
const HOLD_COUNT_TEXT: String = "Hold: %d"
const TOTAL_COUNT_TEXT: String = "Total: %d"

@export var tap_count: Label
@export var hold_count: Label
@export var total_note_count: Label

@export var marvelous_count: Label
@export var perfect_count: Label
@export var great_count: Label
@export var good_count: Label
@export var miss_count: Label
@export var accuracy: Label

func set_note_count_data(note_data: RGCBeatmap):
	tap_count.text = TAP_COUNT_TEXT % note_data.count_note_count(RGCNoteEvent.NoteType.TAP)
	hold_count.text = HOLD_COUNT_TEXT % note_data.count_note_count(RGCNoteEvent.NoteType.HOLD)
	total_note_count.text = TOTAL_COUNT_TEXT % note_data.count_note_count(RGCNoteEvent.NoteType.ALL)
