class_name ConfirmationPanel extends Control

var can_select : bool = false
@onready var menu_buttons: TextButtonGroup = $"Menu Buttons"

@onready var title_text: Label = %"Title Text"
@onready var main_text: Label = $Text
@onready var positive_label: RichTextLabel = %"Positive Label"
@onready var negative_label: RichTextLabel = %"Negative Label"
@onready var negative_button: MenuText = %"Negative Button"
@onready var positive_button: MenuText = %"Positive Button"
@onready var left_marker_position: Marker2D = %"Left Marker Position"
@onready var center_marker_position: Marker2D = %"Center Marker Position"

var positive_callable : Callable
var negative_callable : Callable

func _ready() -> void:
	visible = false
	#EventBus.trigger_end_day.connect(_on_trigger_end_day)
	
func _on_positive_button_press() -> void:
	if !can_select:
		return
	AudioManager.play_sfx("click1")
	FlowController.unpause_game()
	visible = false
	#FlowController.end_day()
	can_select = false
	positive_callable.call_deferred()
	
func _on_negative_button_press() -> void:
	if !can_select: 
		return
	AudioManager.play_sfx("click1")
	FlowController.unpause_game()
	visible = false
	can_select = false
	negative_callable.call_deferred()

#func _on_trigger_end_day() -> void:
	#visible = true
	#FlowController.pause_game(self)
	#can_select = false
	#await get_tree().process_frame
	#can_select = true

func show_positive(title : String, text : String, button_text : String, and_then : Callable):
	FlowController.pause_game(self)
	negative_button.visible = false
	positive_button.position = center_marker_position.position
	title_text.text = title
	main_text.text = text
	positive_label.text = button_text
	positive_callable = and_then
	visible = true
	can_select =true

func show_positive_negative(title : String, text : String, positive_text : String, and_then_positive : Callable,negative_text : String, and_then_negative : Callable):
	FlowController.pause_game(self)
	negative_button.visible = true
	positive_button.position = left_marker_position.position
	title_text.text = title
	main_text.text = text
	positive_label.text = positive_text
	negative_label.text = negative_text
	positive_callable = and_then_positive
	negative_callable = and_then_negative
	can_select = true
	visible = true



	
