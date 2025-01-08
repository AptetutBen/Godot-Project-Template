extends Control

@onready var button_group: TextButtonGroup = $"Button Group"

func _ready() -> void:
	visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if(!FlowController.panel_can_work(self)):
			return
		if get_tree().paused:
			_unpause()
		else:
			_pause()

func _pause():
	FlowController.pause_game(self)
	visible = true
	button_group.enable()

func _unpause():
	FlowController.unpause_game()
	visible = false

func _on_quit_button_button_action() -> void:
	AudioManager.play_sfx("click1")
	FlowController.load_main_menu()


func _on_resume_button_button_action() -> void:
	AudioManager.play_sfx("click1")
	_unpause()
