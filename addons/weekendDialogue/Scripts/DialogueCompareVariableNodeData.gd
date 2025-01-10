class_name DialogueCompareVariableNodeData extends DialogueNodeData

@export var key : String
@export var default_connected_node : int = -1
@export var connections = []

func get_next_node():
	
	if connections.size() == 0:
		return default_connected_node
	
	var saved_value = SaveController.get_value(key,"")
	
	if saved_value == "":
		return default_connected_node
	
	for connection : String in connections:
		if connection[0] == saved_value:
			return connection[1]
			
	return default_connected_node
