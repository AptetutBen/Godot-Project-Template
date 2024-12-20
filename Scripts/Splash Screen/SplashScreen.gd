extends Node

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	FlowController.load_main_menu()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		FlowController.load_main_menu()
