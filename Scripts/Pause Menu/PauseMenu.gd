extends Control

func _ready() -> void:
	visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if get_tree().paused:
			_unpause()
		else:
			_pause()

func _pause():
	get_tree().paused = true
	visible = true

func _unpause():
	get_tree().paused = false
	visible = false

func _on_quit_button_button_action() -> void:
	AudioManager.play_sfx("click1")
	get_tree().paused = false
	FlowController.load_main_menu()


func _on_resume_button_button_action() -> void:
	AudioManager.play_sfx("click1")
	_unpause()
