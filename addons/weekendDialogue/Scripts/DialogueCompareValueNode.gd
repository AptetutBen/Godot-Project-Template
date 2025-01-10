@tool
class_name DialogueCompareVariableNode extends DialogueNode 

@onready var key_edit: TextEdit = %"Key Edit"

var key : String


func _ready() -> void:
	key_edit.text_changed.connect(_on_key_text_changed)

func _on_key_text_changed():
	key = key_edit.text

func initiliase(data : DialogueNodeData):
	await self.ready
	dialogue_data = data
	id = data.id
	position_offset = dialogue_data.position
	name= "Compare Variable Node_%s"%[dialogue_data.id]
	title = name
	key = data.key
	key_edit.text = key


func initilise_new(pos : Vector2, node_number : int):
	await self.ready
	dialogue_data = DialogueGetVariableNodeData.new()
	dialogue_data.position = pos
	id = node_number
	position_offset = pos
	name = "Compare Variable Node_%s"%[node_number]
	title = name

func save_node(connections : Array) -> void:
	dialogue_data.position = position_offset
	dialogue_data.id = id
	dialogue_data.connected_node_id_true = -1
	dialogue_data.connected_node_id_false = -1
	dialogue_data.key = key
	dialogue_data.size = size
	
	for i in connections.size():
		if connections[i][0] == 0:
			dialogue_data.connected_node_id_true = connections[i][1]
		elif connections[i][0] == 1:
			dialogue_data.connected_node_id_false = connections[i][1]
