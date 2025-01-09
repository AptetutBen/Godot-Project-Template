class_name IntroSequences extends Node

@export var start_sequence : IntroSequence
@export var sequences : Array[IntroSequence]
@onready var fade_panel: FadePanel = $"CanvasLayer/Fade Panel"

func start_default() -> void:
	fade_panel.disable()
	FollowCamera.Instance.set_default_start()

func start_intro_sequence() -> void:
	AudioManager.fade_current_song()
	start_sequence.start_sequence()
	#sequences.pick_random().start_sequence()
