class_name DialogueSetVariableNode extends DialogueNode 

signal delete_node(node : DialogueStartNode)

var dialogeVariableNodeData : DialogueSetVariableNodeData

func _ready() -> void:
	delete_request.connect(_on_delete_request)
	dragged.connect(_on_dragged)
	
func initiliase(data : DialogueSetVariableNodeData):
	dialogeVariableNodeData = data

	position_offset = dialogeVariableNodeData.position
	name= "Set Variable Node_%s"%[dialogeVariableNodeData.id]
	title = name

func initilise_new(pos : Vector2, node_number : int):
	dialogeVariableNodeData = DialogueSetVariableNodeData.new()
	dialogeVariableNodeData.position = pos
	id = node_number
	position_offset = pos
	name = "Set Variable Node_%s"%[node_number]
	title = name

func save_node(connections : Array) -> void:
	dialogeVariableNodeData.position = position_offset
	dialogeVariableNodeData.id = id
	
	if connections.size() == 0:
		dialogeVariableNodeData.connected_node_id = -1
	if connections.size() == 1:
		dialogeVariableNodeData.connected_node_id = connections[0][0]
	elif connections.size() > 1:
		printerr("Start node %s has more than one connection"%dialogeVariableNodeData.id)

func _on_dragged(from: Vector2, to: Vector2) -> void:
	dialogeVariableNodeData.position = position_offset

func _on_delete_request() -> void:
	delete_node.emit(self)

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
