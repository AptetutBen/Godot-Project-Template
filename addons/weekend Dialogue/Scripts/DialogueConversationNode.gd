class_name DialogueConversationNode extends DialogueNode

signal edit_node(node: DialogueConversationNode)
signal delete_node(node : DialogueConversationNode)

@onready var preview_text: RichTextLabel = %"Preview Text"
@onready var add_option_button: Button = %"Add Option Button"
@onready var character_picker: OptionButton = %"Character Picker"

@export var option_prefab : PackedScene

var text : String
var character_id : int
var dialogeNodeData : DialogueConversationNodeData

var options : Array[DialogueOptionUI]

func _ready() -> void:
	delete_request.connect(_on_delete_request)
	dragged.connect(_on_dragged)
	add_option_button.pressed.connect(_on_add_option_button_press)
	character_picker.item_selected.connect(_on_item_selected)

func initiliase(data : DialogueConversationNodeData,characters : DialogueCharacters):
	for char : DialogueCharacter in characters.characters:
		character_picker.add_item(char.name,char.id)
	
	dialogeNodeData = data
	position_offset = dialogeNodeData.position
	text = dialogeNodeData.text
	preview_text.text = text
	id = data.id
	name = "Dialogue Node_%s"%[str(id)]
	title = name
	character_id = data.character_id
	for option : DialogueOption in data.options:
		if option.text == "default":
			continue
		_build_option(option)
	
	#var item_index : int = character_picker.get_item_index(character_id)
	character_picker.set

func initilise_new(pos : Vector2, node_id : int,characters : DialogueCharacters):
	
	for char : DialogueCharacter in characters.characters:
		character_picker.add_item(char.name,char.id)
		
	dialogeNodeData = DialogueConversationNodeData.new()
	dialogeNodeData.position = pos
	position_offset = pos
	id = node_id
	name = "Dialogue Node_%s"%[node_id]
	title = name
	
func _on_item_selected(index : int):
	print(index)
	character_id = index

func save_node(connections : Array) -> void:
	dialogeNodeData.position = position_offset
	dialogeNodeData.text = text
	dialogeNodeData.options.clear()
	dialogeNodeData.id = id
	dialogeNodeData.character_id = character_id
	
	if connections.size() == 0:
		return
		
	if options.size() == 0:
		var data : DialogueOption = DialogueOption.new()
		data.text = "default"
		data.linking_node_id = connections[0][0]
		dialogeNodeData.options.append(data)
	else:
		for option : DialogueOptionUI in options:
			option.save()
			dialogeNodeData.options.append(option.dialogue_option)
	
func _on_edit_button_pressed():
	edit_node.emit(self)

func _on_delete_request() -> void:
	print("delete")
	delete_node.emit(self)

func _on_dragged(from: Vector2, to: Vector2) -> void:
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
	_update_links()
	return new_option

func on_remove_option(option : DialogueOptionUI):
	options.erase(option)
	option.queue_free()
	_update_links()
	
func _update_links():
	if options.size() == 0:
		set_slot_enabled_right(2,true)
	else:
		set_slot_enabled_right(2,false)
		for i in options.size():
			set_slot_enabled_right(3 + i,true)
			
		
func _on_preview_text_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		_on_edit_button_pressed()
		selected = true

func is_port_connected(self_port_type: String, self_port: int) -> bool:
	for port_idx in ports_connected[self_port_type].keys():
		if ports_connected[self_port_type][port_idx]:
			return true
	return false

func on_connect(self_port_type: String, self_port: int, other_node: DialogueNode, other_port: int) -> void:
	print("I am connected to ", other_node, " on ", self_port_type, " port ", other_port)
	ports_connected[self_port_type][self_port] = true

func on_disconnect(self_port_type: String, self_port: int, other_node: DialogueNode, other_port: int) -> void:
	print("I am disconnected to ", other_node, " on ", self_port_type, " port ", other_port)
	ports_connected[self_port_type][self_port] = false
