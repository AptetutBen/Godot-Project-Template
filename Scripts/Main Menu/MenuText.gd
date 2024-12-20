class_name MenuText extends RichTextLabel

const template : String = "● [wave amp=50.0 freq=5.0 connected=1]#[/wave]"
var labelText : String
var index : int

@export var normalTheme: Theme 
@export var highlightTheme : Theme 

signal buttonAction
signal onMouseClick(int)

func _ready() -> void:
	labelText = text
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func trigger_action():
	buttonAction.emit()

func select_button() -> void:
	text = template.replace("#",labelText)

func deselect_button() -> void:
	text = labelText
	
func highlight() -> void:
	theme = highlightTheme

func dehighlight() -> void:
	theme = normalTheme
	

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && MOUSE_BUTTON_LEFT && event.is_pressed():
		onMouseClick.emit(index)
		
func _on_mouse_entered() -> void:
	highlight()

func _on_mouse_exited() -> void:
	dehighlight()
