class_name DialogueStartNode extends GraphNode

signal delete_node(node : DialogueStartNode)

var dialogeStartNodeData : DialogueStartNodeData

var linking_node_id : String

func _ready() -> void:
	delete_request.connect(_on_delete_request)
	dragged.connect(_on_dragged)
	
func initiliase(data : DialogueStartNodeData):
	dialogeStartNodeData = data
	position_offset = dialogeStartNodeData.position

func initilise_new(pos : Vector2):
	dialogeStartNodeData = DialogueStartNodeData.new()
	dialogeStartNodeData.position = pos
	position_offset = pos

func save_node() -> void:
	dialogeStartNodeData.position = position_offset
	dialogeStartNodeData.id = name
	dialogeStartNodeData.linking_node = linking_node_id

func _on_dragged(from: Vector2, to: Vector2) -> void:
	dialogeStartNodeData.position = position_offset

func _on_delete_request() -> void:
	delete_node.emit(self)
