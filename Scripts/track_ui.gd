extends Control

@export var rating_label: Label
@export var combo_label: Label

func _ready() -> void:
	RGCSM.add_score.connect(_on_score_manager_add_score)

func update_combo(value: int):
	combo_label.text = str(value)

func _on_score_manager_add_score(rating: RGCScoreManager.Rating) -> void:
	match rating:
		RGCScoreManager.Rating.MISS:
			rating_label.text = "MISS"
		RGCScoreManager.Rating.GOOD:
			rating_label.text = "GOOD"
		RGCScoreManager.Rating.GREAT:
			rating_label.text = "GREAT"
		RGCScoreManager.Rating.PERFECT:
			rating_label.text = "PERFECT"
		RGCScoreManager.Rating.MARVELOUS:
			rating_label.text = "MARVELOUS"
	
	await get_tree().process_frame
	update_combo(RGCSM.combo_count)
