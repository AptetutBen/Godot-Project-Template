@tool
extends Control

@export var dialogueConversationNodePrefab : PackedScene
@export var dialogueStartNodePrefab : PackedScene
@export var dialogueSetVariableNodePrefab : PackedScene
@export var dialogueGetVariableNodePrefab : PackedScene

@export var settings : dialogueSettings

@onready var dialogue_editor: GraphEdit = %"Dialogue Editor"
@onready var text_editor: DialogueTextEditor = %"Text Editor"

@onready var popup_menu: PopupMenu = %PopupMenu
@onready var file_dialog: FileDialog = %FileDialog
@onready var add_menu: PopupMenu = $"Add Menu"

@export var dialogue_data : DialogueData

var dialogue_nodes : Array[GraphNode]
var next_id : int = 1

func _ready() -> void:
	file_dialog.file_selected.connect(on_select_file)
	if settings == null:
		printerr("Settings file not found")
		return
	
	if ResourceLoader.exists(settings.current_dialogue_data_path):
		dialogue_data = load(settings.current_dialogue_data_path)
		_build_graph()
	
	

func _build_graph():
	
	for node in dialogue_nodes:
		remove_node(node)
	next_id = 1
		
	for data : DialogueNodeData in dialogue_data.data:
		if data is DialogueConversationNodeData:
			var newNode : DialogueConversationNode = dialogueConversationNodePrefab.instantiate()
			newNode.set_characters(dialogue_data.characters)
			newNode.edit_node.connect(_on_node_edit_selected)
			_set_node_exsisting(newNode,data)
		elif data is DialogueSetVariableNodeData:
			var newNode : DialogueSetVariableNode = dialogueSetVariableNodePrefab.instantiate()
			_set_node_exsisting(newNode,data)
		elif data is DialogueGetVariableNodeData:
			var newNode : DialogueGetVariableNode = dialogueGetVariableNodePrefab.instantiate()
			_set_node_exsisting(newNode,data)
		elif data is DialogueStartNodeData:
			var newNode : DialogueStartNode = dialogueStartNodePrefab.instantiate()
			_set_node_exsisting(newNode,data)
			
	
	for connection_string in dialogue_data.connnections:
		var connection_parts : PackedStringArray = connection_string.split(",")

		if connection_parts.size() != 4:
			printerr("Connected string not correct %s"%connection_string)
			continue

		_on_dialogue_editor_connection_request(
			connection_parts[0],
			int(connection_parts[1]),
			connection_parts[2],
			int(connection_parts[3])
		)
		
func _on_right_click(node : DialogueNode) -> void:
	popup_menu.show_popup(node)

func _on_node_edit_selected(node : DialogueConversationNode):
	text_editor.enable(node)

func _on_open_file():
	file_dialog.visible = true

func on_select_file(path:String):
	dialogue_data = load(path)
	settings.current_dialogue_data_path = path
	ResourceSaver.save(settings)
	_build_graph();

func remove_node(node : DialogueNode):
	var connections : Array
	
	for con in dialogue_editor.get_connection_list():
		if con.to_node == node.name || con.from_node == node.name :
			connections.append(con)
	
	for con in connections:
		_on_dialogue_editor_disconnection_request(con.from_node,con.from_port,con.to_node,con.to_port)

	dialogue_nodes.erase(node)
	node.queue_free()

func _on_save_pressed():
	dialogue_data.data.clear()
	dialogue_data.connnections.clear()
	
	for node in dialogue_nodes:
		
		var connections : Array
		for con in dialogue_editor.get_connection_list():
			if con.from_node == node.name:
				var to_node : DialogueNode = get_dialogue_node(con.to_node)
				connections.append([con.from_port,to_node.id])
		
		node.save_node(connections)
		
		if node is DialogueConversationNode:
			dialogue_data.data.append(node.dialogue_data)
		elif node is DialogueStartNode:
			dialogue_data.data.append(node.dialogue_data)
		elif node is DialogueSetVariableNode:
			dialogue_data.data.append(node.dialogue_data)
		elif node is DialogueGetVariableNode:
			dialogue_data.data.append(node.dialogue_data)
	
	for con in dialogue_editor.get_connection_list():
		var from_node : String = con.from_node
		var from_port : int = con.from_port
		var to_node : String = con.to_node
		var to_port : int = con.to_port
		var connection : String = "%s,%s,%s,%s"%[from_node,str(from_port),to_node,str(to_port)]
		dialogue_data.connnections.append(connection)
	
	ResourceSaver.save(dialogue_data)
	print("Data Saved")

func _find_node(node_name : StringName) -> GraphNode:
	for node : GraphNode in dialogue_nodes:
		if node.name == node_name:
			return node
	return null

func connect_out_node(node_id : String):
	dialogue_data

func _on_dialogue_editor_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	for con in dialogue_editor.get_connection_list():
		if con.from_node == from_node and con.from_port == from_port:
			_on_dialogue_editor_disconnection_request(con.from_node,con.from_port,con.to_node,con.to_port)
	dialogue_editor.connect_node(from_node, from_port, to_node, to_port)

	var from_node_inst = get_dialogue_node(from_node)
	var to_node_inst = get_dialogue_node(to_node)
	
	from_node_inst.on_connect("output", from_port, to_node_inst, to_port)
	to_node_inst.on_connect("input", to_port, from_node_inst, from_port)

func _on_dialogue_editor_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	dialogue_editor.disconnect_node(from_node, from_port, to_node, to_port)

	var from_node_inst = get_dialogue_node(from_node)
	var to_node_inst = get_dialogue_node(to_node)

	from_node_inst.on_disconnect("output", from_port, to_node_inst, to_port)
	to_node_inst.on_disconnect("input", to_port, from_node_inst, from_port)

func get_dialogue_node(node_name : String) -> DialogueNode:
	return dialogue_editor.find_child(node_name,false,false)

# Adding nodes

func _on_add_start_node_pressed() -> void:
	_set_node_basics(dialogueStartNodePrefab.instantiate())

func _on_add_node_pressed() -> void:
	add_menu. visible = true

func _on_add_set_variabe_node_pressed() -> void:
	_set_node_basics( dialogueSetVariableNodePrefab.instantiate())

func _on_add_get_variabe_node_pressed() -> void:
	_set_node_basics(dialogueGetVariableNodePrefab.instantiate())

func _set_node_basics(newNode : DialogueNode) -> void:
	newNode.initilise_new(Vector2(100,100),next_id)
	next_id += 1
	add_node_common(newNode)
	add_menu.visible = false

func _set_node_exsisting(newNode : DialogueNode,data : DialogueNodeData):
	newNode.initiliase(data)
	next_id = max(next_id,data.id + 1)
	add_node_common(newNode)

func add_node_common(newNode : DialogueNode) -> void:
	dialogue_editor.add_child(newNode)
	dialogue_nodes.append(newNode)
	newNode.delete_node.connect(remove_node)
	newNode.right_click.connect(_on_right_click)


func _on_compare_variable_button_pressed() -> void:
	pass # Replace with function body.

func _on_add_conversation_node_pressed() -> void:
	var newNode : DialogueConversationNode = dialogueConversationNodePrefab.instantiate() as DialogueConversationNode
	newNode.edit_node.connect(_on_node_edit_selected)
	newNode.set_characters(dialogue_data.characters)
	_set_node_basics(newNode)


func _on_add_menu_id_pressed(id: int) -> void:
	pass # Replace with function body.
