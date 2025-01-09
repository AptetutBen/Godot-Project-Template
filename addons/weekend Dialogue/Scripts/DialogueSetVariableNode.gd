class_name DialogueSetVariableNode extends DialogueNode 

func _ready() -> void:
	delete_request.connect(_on_delete_request)
	dragged.connect(_on_dragged)
	
func initiliase(data : DialogueNodeData):
	dialogue_data = data
	id = data.id
	position_offset = data.position
	name= "Set Variable Node_%s"%[data.id]
	title = name

func initilise_new(pos : Vector2, node_number : int):
	dialogue_data = DialogueSetVariableNodeData.new()
	dialogue_data.position = pos
	id = node_number
	position_offset = pos
	name = "Set Variable Node_%s"%[node_number]
	title = name

func save_node(connections : Array) -> void:
	dialogue_data.position = position_offset
	dialogue_data.id = id
	
	if connections.size() == 0:
		dialogue_data.connected_node_id = -1
	if connections.size() == 1:
		dialogue_data.connected_node_id = connections[0][0]
	elif connections.size() > 1:
		printerr("Start node %s has more than one connection"%dialogue_data.id)

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
