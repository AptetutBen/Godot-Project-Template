class_name DialogueConversationNode extends DialogueNode

signal edit_node(node: DialogueConversationNode)

@onready var preview_text: RichTextLabel = %"Preview Text"
@onready var add_option_button: Button = %"Add Option Button"
@export var character_picker: OptionButton

@export var option_prefab : PackedScene

var text : String
var character_id : int

var options : Array[DialogueOptionUI]

func _ready() -> void:
	delete_request.connect(_on_delete_request)
	dragged.connect(_on_dragged)
	add_option_button.pressed.connect(_on_add_option_button_press)
	character_picker.item_selected.connect(_on_item_selected)

func initiliase(data : DialogueNodeData):
	await self.ready
	dialogue_data = data
	position_offset = dialogue_data.position
	text = dialogue_data.text
	preview_text.text = text
	id = data.id
	name = "Dialogue Node_%s"%[str(id)]
	title = name
	character_id = data.character_id
	for option : DialogueOption in data.options:
		if option.text == "default":
			continue
		_build_option(option)
	character_picker.select(character_id)

func set_characters(characters : DialogueCharacters) -> void:
	for char : DialogueCharacter in characters.characters:
		character_picker.add_item(char.name,char.id)
	character_picker.allow_reselect = true


func initilise_new(pos : Vector2, node_id : int):
	await self.ready
	dialogue_data = DialogueConversationNodeData.new()
	character_picker.select(0)
	dialogue_data.position = pos
	position_offset = pos
	id = node_id
	name = "Dialogue Node_%s"%[node_id]
	title = name
	
func _on_item_selected(index : int):
	character_id = index

func save_node(connections : Array) -> void:
	dialogue_data.position = position_offset
	dialogue_data.text = text
	dialogue_data.options.clear()
	dialogue_data.id = id
	dialogue_data.character_id = character_id
	
	if connections.size() == 0:
		return
	elif connections.size() == 1:
		var data : DialogueOption = DialogueOption.new()
		data.text = "default"
		data.linking_node_id = connections[0][1]
		dialogue_data.options.append(data)
	else:
		for option : DialogueOptionUI in options:
			option.save()
			dialogue_data.options.append(option.dialogue_option)
	
func _on_edit_button_pressed():
	edit_node.emit(self)
	
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

func _on_preview_text_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			edit_node.emit(self)
