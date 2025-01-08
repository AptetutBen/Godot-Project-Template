extends Control

@export var dialogueNodePrefab : PackedScene
@export var dialogueStartNodePrefab : PackedScene
@export var dialogueSetVariableNodePrefab : PackedScene

@onready var dialogue_editor: GraphEdit = %"Dialogue Editor"
@onready var text_editor: DialogueTextEditor = %"Text Editor"

@export var dialogue_data : DialogueData

var dialogue_nodes : Array[GraphNode]
var next_id : int

func _ready() -> void:
	for node : DialogueConversationNodeData in dialogue_data.data:
		var newNode : DialogueConversationNode = _add_new_dialogue_node()
		newNode.initiliase(node,dialogue_data.characters)
		
		next_id = max(next_id,node.id)
		
	for node in dialogue_data.start_data:
		var newNode : DialogueStartNode = _add_new_start_dialogue_node()
		newNode.initiliase(node)
		
		next_id = max(next_id,node.id)
	
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
		

func _on_add_node_pressed() -> void:
	var newNode : DialogueConversationNode = _add_new_dialogue_node()
	newNode.initilise_new(Vector2(100,100),next_id+1,dialogue_data.characters)
	next_id += 1

func _add_new_dialogue_node() -> DialogueConversationNode:
	var newNode : DialogueConversationNode = dialogueNodePrefab.instantiate() as DialogueConversationNode
	dialogue_editor.add_child(newNode)
	dialogue_nodes.append(newNode)
	newNode.edit_node.connect(_on_node_edit_selected)
	newNode.delete_node.connect(remove_dialogue_node)
	return newNode

func _on_add_start_node_pressed() -> void:
	var newNode : DialogueStartNode = _add_new_start_dialogue_node()
	newNode.initilise_new(Vector2(100,100),next_id + 1)
	next_id += 1
		
func _add_new_start_dialogue_node() -> DialogueStartNode:
	var newNode : DialogueStartNode = dialogueStartNodePrefab.instantiate() as DialogueStartNode
	dialogue_editor.add_child(newNode)
	dialogue_nodes.append(newNode)
	newNode.delete_node.connect(remove_dialogue_node)
	return newNode

func _on_node_edit_selected(node : DialogueConversationNode):
	text_editor.enable(node)

func remove_dialogue_node(node : DialogueConversationNode):
	var connections : Array
	
	for con in dialogue_editor.get_connection_list():
		if con.to_node == node.name || con.from_node == node.name :
			connections.append(con)
	
	for con in connections:
		_on_dialogue_editor_disconnection_request(con.from_node,con.from_port,con.to_node,con.to_port)
		print("removed one")
	dialogue_nodes.erase(node)
	node.queue_free()

func _on_save_pressed():
	dialogue_data.data.clear()
	dialogue_data.start_data.clear()
	dialogue_data.connnections.clear()
	
	for node in dialogue_nodes:
		
		var connections : Array
		for con in dialogue_editor.get_connection_list():
			if con.from_node == node.name:
				var to_node : DialogueNode = get_dialogue_node(con.to_node)
				connections.append([to_node.id,con.from_port])
		
		node.save_node(connections)
		
		if node is DialogueConversationNode:
			dialogue_data.data.append(node.dialogeNodeData)
		elif node is DialogueStartNode:
			dialogue_data.start_data.append(node.dialogeStartNodeData)
	
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
		if con.to_node == to_node and con.to_port == to_port:
			return
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


func _on_add_set_variabe_node_pressed() -> void:
	pass
	#var newNode : DialogueSetVariableNode = _add_new_start_dialogue_node()
	#newNode.initilise_new(Vector2(100,100),next_id + 1)
	#next_id += 1
