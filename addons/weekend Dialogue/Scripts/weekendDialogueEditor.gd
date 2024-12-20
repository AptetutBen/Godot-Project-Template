extends Control

@export var dialogueNode : PackedScene
@onready var dialogue_editor: GraphEdit = %"Dialogue Editor"

var nodeId : int = 0

func _on_add_node_pressed() -> void:
	var newNode : GraphNode = dialogueNode.instantiate() as GraphNode
	dialogue_editor.add_child(newNode)
	newNode.position = dialogue_editor.scroll_offset
	
	nodeId += 1


func _on_dialogue_editor_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	
	
	dialogue_editor.connect_node(from_node,from_port,to_node,to_port)
