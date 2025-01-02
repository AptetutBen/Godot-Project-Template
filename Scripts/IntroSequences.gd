class_name IntroSequences extends Node

@export var sequences : Array[IntroSequence]
@onready var fade_panel: FadePanel = $"CanvasLayer/Fade Panel"

func start_default() -> void:
	fade_panel.disable()
	FollowCamera.Instance.set_default_start()

func start_intro_sequence() -> void:
	AudioManager.fade_current_song()
	sequences.pick_random().start_sequence()
