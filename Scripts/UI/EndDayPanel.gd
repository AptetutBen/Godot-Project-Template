extends Control

@onready var positive_button: MenuText = %"Positive Button"
@onready var negative_button: MenuText = %"Negative Button"

func _ready() -> void:
	visible = false
	EventBus.trigger_end_day.connect(_on_trigger_end_day)
	positive_button.buttonAction.connect(_on_positive_button_press)
	negative_button.buttonAction.connect(_on_negative_button_press)

func _on_positive_button_press() -> void:
	AudioManager.play_sfx("click1")
	FlowController.end_day()
	
func _on_negative_button_press() -> void:
	AudioManager.play_sfx("click1")
	FlowController.unpause_game()
	visible = false

func _on_trigger_end_day() -> void:
	visible = true
	FlowController.pause_game(self)
