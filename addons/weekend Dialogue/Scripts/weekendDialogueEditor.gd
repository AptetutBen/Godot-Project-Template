extends Control

@export var dialogueNodePrefab : PackedScene
@onready var dialogue_editor: GraphEdit = %"Dialogue Editor"
@onready var text_editor: DialogueTextEditor = %"Text Editor"
@export var dialogue_data : DialogueData

var dialogue_nodes : Array[DialogueNode]

var nodeId : int = 0

func _ready() -> void:
	for node in dialogue_data.data:
		var newNode : DialogueNode = _add_new_dialogue_node()
		newNode.initiliase(node)

func _on_add_node_pressed() -> void:
	var newNode : DialogueNode = _add_new_dialogue_node()
	newNode.initilise_new(Vector2(100,100))

func _add_new_dialogue_node() -> DialogueNode:
	var newNode : DialogueNode = dialogueNodePrefab.instantiate() as DialogueNode
	dialogue_editor.add_child(newNode)
	dialogue_nodes.append(newNode)
	newNode.edit_node.connect(_on_node_edit_selected)
	nodeId += 1
	
	return newNode

func _on_node_edit_selected(node : DialogueNode):
	text_editor.enable(node)
	

func remove_node(node : DialogueNode):
	dialogue_nodes.erase(node)

func _on_save_pressed():
	dialogue_data.data.clear()
	
	for node in dialogue_nodes:
		node.save_node()
		dialogue_data.data.append(node.dialogeNodeData)
	
	ResourceSaver.save(dialogue_data)
	print("Data Saved")
	

func _on_dialogue_editor_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	
	dialogue_editor.connect_node(from_node,from_port,to_node,to_port)
