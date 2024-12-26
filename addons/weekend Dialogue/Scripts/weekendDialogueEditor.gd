extends Control

@export var dialogueNodePrefab : PackedScene
@export var dialogueStartNodePrefab : PackedScene
@onready var dialogue_editor: GraphEdit = %"Dialogue Editor"
@onready var text_editor: DialogueTextEditor = %"Text Editor"
@export var dialogue_data : DialogueData

var dialogue_nodes : Array[GraphNode]

func _ready() -> void:
	for node in dialogue_data.data:
		var newNode : DialogueNode = _add_new_dialogue_node()
		newNode.initiliase(node)
		
	for node in dialogue_data.start_data:
		var newNode : DialogueStartNode = _add_new_start_dialogue_node()
		newNode.initiliase(node)

func _on_add_node_pressed() -> void:
	var newNode : DialogueNode = _add_new_dialogue_node()
	newNode.initilise_new(Vector2(100,100))

func _add_new_dialogue_node() -> DialogueNode:
	var newNode : DialogueNode = dialogueNodePrefab.instantiate() as DialogueNode
	dialogue_editor.add_child(newNode)
	dialogue_nodes.append(newNode)
	newNode.edit_node.connect(_on_node_edit_selected)
	newNode.delete_node.connect(remove_dialogue_node)
	return newNode

func _on_add_start_node_pressed() -> void:
	var newNode : DialogueStartNode = _add_new_start_dialogue_node()
	newNode.initilise_new(Vector2(100,100))
		
func _add_new_start_dialogue_node() -> DialogueStartNode:
	var newNode : DialogueStartNode = dialogueStartNodePrefab.instantiate() as DialogueStartNode
	dialogue_editor.add_child(newNode)
	dialogue_nodes.append(newNode)
	newNode.delete_node.connect(remove_dialogue_node)
	return newNode

func _on_node_edit_selected(node : DialogueNode):
	text_editor.enable(node)

func remove_dialogue_node(node : DialogueNode):
	dialogue_nodes.erase(node)
	node.queue_free()

func _on_save_pressed():
	dialogue_data.data.clear()
	dialogue_data.start_data.clear()
	
	for node in dialogue_nodes:
		node.save_node()
		if node is DialogueNode:
			dialogue_data.data.append(node.dialogeNodeData)
		elif node is DialogueStartNode:
			dialogue_data.start_data.append(node.dialogeStartNodeData)
	
	ResourceSaver.save(dialogue_data)
	print("Data Saved")

func _find_node(node_name : StringName) -> GraphNode:
	for node : GraphNode in dialogue_nodes:
		if node.name == node_name:
			return node
	return null

func _on_dialogue_editor_connection_request(from_node_name: StringName, from_port: int, to_node_name: StringName, to_port: int) -> void:
	var from_node : GraphNode = _find_node(from_node_name)
	var to_node : GraphNode = _find_node(to_node_name)

	dialogue_editor.connect_node(from_node_name,from_port,to_node_name,to_port)
	
	print (from_node)
	print(to_node)

func connect_out_node(node_id : String):
	dialogue_data
	


func _on_dialogue_editor_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	print("here")


func _on_dialogue_editor_delete_nodes_request(nodes: Array[StringName]) -> void:
	print('there')
