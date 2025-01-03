extends Control

@onready var positive_button: MenuText = %"Positive Button"
@onready var negative_button: MenuText = %"Negative Button"

var can_select : bool = false

func _ready() -> void:
	visible = false
	EventBus.trigger_end_day.connect(_on_trigger_end_day)
	positive_button.buttonAction.connect(_on_positive_button_press)
	negative_button.buttonAction.connect(_on_negative_button_press)
	
func _on_positive_button_press() -> void:
	if can_select:
		return
	AudioManager.play_sfx("click1")
	FlowController.end_day()
	can_select = false
	
func _on_negative_button_press() -> void:
	if can_select: 
		return
	AudioManager.play_sfx("click1")
	FlowController.unpause_game()
	visible = false
	can_select = false

func _on_trigger_end_day() -> void:
	visible = true
	FlowController.pause_game(self)
	can_select = false
	await get_tree().create_timer(1).timeout
	can_select = true
