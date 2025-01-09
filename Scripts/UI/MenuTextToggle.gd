class_name MenuTextToggle extends MenuText

@onready var fullscreen_toggle_text: RichTextLabel = %"Fullscreen Toggle Text"

func trigger_action():
	buttonAction.emit()
	
