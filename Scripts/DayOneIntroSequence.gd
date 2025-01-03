extends IntroSequence

@onready var player_end_marker: Marker3D = $"Player End Marker"

func start_sequence() -> void:
	visible = true
	
	Player.Instance.enabled = false
	Player.Instance.position = player_marker.position
	FollowCamera.Instance.start_watch_camera(camera_marker)
	
	AudioManager.play_sfx_fade(audio_clip,true)
	
	fade_panel.fade_in(1,3)
	await fade_panel.finished_fade
	Player.Instance.play_sequence(player_end_marker.global_position)
	#await get_tree().create_timer(3).timeout
	#FollowCamera.Instance.end_day_sequence()
	#Player.Instance.enabled = true
	#await get_tree().create_timer(3).timeout
	#visible = false
