class_name IntroSequence extends Node3D

@onready var player_marker: Marker3D = $"Player Marker"
@onready var camera_marker: Marker3D = $"Camera Marker"


@onready var fade_panel: FadePanel = $"../CanvasLayer/Fade Panel"
@onready var letter_mesh: MeshInstance3D = %"Text Mesh"

@export var audio_clip: String = "Morning Birds"

func start_sequence() -> void:
	visible = true
	var text_mesh = letter_mesh.mesh as TextMesh
	var day_number : int = SaveController.get_current_day() + 1
	text_mesh.text = "Day %s"%str(day_number)
	
	Player.Instance.enabled = false
	Player.Instance.position = player_marker.position
	FollowCamera.Instance.start_day_sequence(camera_marker)
	
	AudioManager.play_sfx_fade(audio_clip,true)
	
	fade_panel.fade_in(1,3)
	await fade_panel.finished_fade
	await get_tree().create_timer(3).timeout
	FollowCamera.Instance.end_day_sequence()
	Player.Instance.enabled = true
	await get_tree().create_timer(3).timeout
	visible = false
	AudioManager.play_music("Gentle Reflections",4)
