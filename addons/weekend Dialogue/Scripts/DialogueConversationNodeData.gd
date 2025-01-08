class_name DialogueData extends Resource

@export var start_data : Array[DialogueStartNodeData]
@export var data : Array[DialogueConversationNodeData]
@export var connnections : Array[String]
@export var characters : DialogueCharacters

func get_random_dialogue() -> DialogueConversationNodeData:
	return get_node_from_start(start_data.pick_random().first_node_id)

func get_all_start_nodes() -> Array[DialogueStartNodeData]:
	return start_data

func get_node_from_start(key : String) -> DialogueConversationNodeData:
	for node : DialogueStartNodeData in start_data:
		if node.start_key == key:
			return get_dialogue_node(node.first_node_id)
	printerr("Can't find start node id: %s" % [key])
	return null

func get_dialogue_node(id : int) -> DialogueConversationNodeData:
	for node : DialogueConversationNodeData in data:
		if node.id == id:
			#process node
			node.dialoge_data = self
			return node
	printerr("Can't find node id: %s" % [id])
	return null

func get_next_node(current_node : DialogueConversationNodeData, selected_option = 0) -> DialogueConversationNodeData:
	match current_node.options.size():
		0:
			return null
		1:
			return get_dialogue_node(current_node.options[0].linking_node_id)
		_:
			return get_dialogue_node(current_node.options[selected_option].linking_node_id)
	
	
	
