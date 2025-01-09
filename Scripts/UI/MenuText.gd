class_name MenuText extends Control

signal buttonAction
signal highlight_button(index : int)
signal on_click(index : int)

var labelText : String
var index : int

@export var key : String # used for remote activation and deactivation of button

@onready var texture_rect: TextureRect = $"TextureRect"

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_gui_input)

func trigger_action():
	buttonAction.emit()

func select_button() -> void:
	texture_rect.visible = true

func deselect_button() -> void:
	texture_rect.visible = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && MOUSE_BUTTON_LEFT && event.is_pressed():
		on_click.emit(index)
		
func _on_mouse_entered() -> void:
	highlight_button.emit(index)

func _on_mouse_exited() -> void:
	pass
