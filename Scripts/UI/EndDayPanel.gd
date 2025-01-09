extends Control

var can_select : bool = false
@onready var menu_buttons: TextButtonGroup = $"Menu Buttons"

func _ready() -> void:
	visible = false
	EventBus.trigger_end_day.connect(_on_trigger_end_day)
	
func _on_positive_button_press() -> void:
	if !can_select:
		return
	AudioManager.play_sfx("click1")
	FlowController.end_day()
	can_select = false
	
func _on_negative_button_press() -> void:
	if !can_select: 
		return
	AudioManager.play_sfx("click1")
	FlowController.unpause_game()
	visible = false
	can_select = false

func _on_trigger_end_day() -> void:
	visible = true
	FlowController.pause_game(self)
	can_select = false
	await get_tree().process_frame
	can_select = true
	
