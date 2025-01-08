extends Control

var can_select : bool = false

func _ready() -> void:
	visible = false
	EventBus.trigger_end_day.connect(_on_trigger_end_day)
	
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
