class_name DialogueNode extends GraphNode

signal edit_node(node: DialogueNode)

@onready var preview_text: RichTextLabel = %"Preview Text"
#@onready var editor_group : VBoxContainer = %"Editor Group"
@onready var add_option_button: Button = %"Add Option Button"
@onready var edit_button: Button = %"Edit Button"

@export var option_prefab : PackedScene

var text : String
var dialogeNodeData : DialogueNodeData

var options : Array[DialogueOptionUI]

func _ready() -> void:
	delete_request.connect(_on_delete_request)
	dragged.connect(_on_dragged)
	add_option_button.pressed.connect(_on_add_option_button_press)
	edit_button.pressed.connect(_on_edit_button_pressed)

func initiliase(data : DialogueNodeData):
	dialogeNodeData = data
	position_offset = dialogeNodeData.position
	text = dialogeNodeData.text
	preview_text.text = text
	
	for option : DialogueOption in data.options:
		_build_option(option)

func initilise_new(pos : Vector2):
	dialogeNodeData = DialogueNodeData.new()
	dialogeNodeData.position = pos
	position_offset = pos

func save_node() -> void:
	dialogeNodeData.position = position_offset
	dialogeNodeData.text = text
	dialogeNodeData.options.clear()
	
	for option : DialogueOptionUI in options:
		option.save()
		dialogeNodeData.options.append(option.dialogue_option)
	
func _on_edit_button_pressed():
	edit_node.emit(self)

func _on_delete_request() -> void:
	print("Delete Request")

func _on_dragged(from: Vector2, to: Vector2) -> void:
	print("Position Changed %s"%[to])
	dialogeNodeData.position = position_offset
	
func on_text_changed(new_text : String) -> void:
	text = new_text
	preview_text.text = text
	
func _on_add_option_button_press():
	var newOptionsUI : DialogueOptionUI = _add_option()
	newOptionsUI.initialise_new()

func _build_option(data : DialogueOption):
	var newOptionsUI : DialogueOptionUI = _add_option()
	newOptionsUI.initialise(data)

func _add_option() -> DialogueOptionUI:
	var new_option : DialogueOptionUI = option_prefab.instantiate() as DialogueOptionUI
	add_child(new_option)
	new_option.delete_request.connect(on_remove_option)
	options.append(new_option)
	return new_option

func on_remove_option(option : DialogueOptionUI):
	options.erase(option)
	
	option.queue_free()
	print("Removing Option")
		
func _on_preview_text_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		_on_edit_button_pressed()
		selected = true
