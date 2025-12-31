extends Node

@export var music_player: AudioStreamPlayer
@export var hit_sound_player: AudioStreamPlayer

func _on_audio_play_timeout() -> void:
	if not music_player.stream:
		push_error("未加载音频！")
		return
	
	music_player.play()
