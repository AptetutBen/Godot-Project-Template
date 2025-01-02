class_name IntroSequences extends Node

@export var sequences : Array[IntroSequence]

func start_intro_sequence() -> void:
	sequences.pick_random().start_sequence()
