class_name DialogueStartNode extends DialogueNode

signal delete_node(node : DialogueStartNode)

var dialogeStartNodeData : DialogueStartNodeData
@onready var start_key_text_edit: TextEdit = $"HBoxContainer/Start Key Text Edit"

var linking_node_id : String

func _ready() -> void:
	delete_request.connect(_on_delete_request)
	dragged.connect(_on_dragged)
	
func initiliase(data : DialogueStartNodeData):
	dialogeStartNodeData = data
	start_key_text_edit.text = data.start_key
	position_offset = dialogeStartNodeData.position
	name= "Start Node_%s"%[dialogeStartNodeData.id]
	title = name

func initilise_new(pos : Vector2, node_number : int):
	dialogeStartNodeData = DialogueStartNodeData.new()
	dialogeStartNodeData.position = pos
	id = node_number
	position_offset = pos
	name = "Start Node_%s"%[node_number]
	title = name

func save_node(connections : Array) -> void:
	dialogeStartNodeData.position = position_offset
	dialogeStartNodeData.id = id
	dialogeStartNodeData.start_key = start_key_text_edit.text
	
	if connections.size() == 1:
		dialogeStartNodeData.first_node_id = connections[0][0]
	elif connections.size() > 1:
		printerr("Start node %s has more than one connection")	

func _on_dragged(from: Vector2, to: Vector2) -> void:
	dialogeStartNodeData.position = position_offset

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
