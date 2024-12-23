class_name DialogueData extends Resource

@export var start_data : Array[StartDialogueNodeData]
@export var data : Array[DialogueNodeData]

func get_random_dialogue() -> DialogueNodeData:
	return get_node_from_start(start_data.pick_random().first_node_id)

func get_all_start_nodes() -> Array[StartDialogueNodeData]:
	return start_data

func get_node_from_start(key : String) -> DialogueNodeData:
	for node : StartDialogueNodeData in start_data:
		if node.start_key == key:
			return get_node(node.first_node_id)
	printerr("Can't find start node id: %s" % [key])
	return null

func get_node(id : String) -> DialogueNodeData:
	for node : DialogueNodeData in data:
		if node.id == id:
			#process node
			node.dialoge_data = self
			return node
	printerr("Can't find node id: %s" % [id])
	return null

func get_next_node(current_node : DialogueNodeData, selected_option = 0) -> DialogueNodeData:
	match current_node.options.size():
		0:
			return null
		1:
			return get_node(current_node.options[0].node_id)
		_:
			return get_node(current_node.options[selected_option].node_id)
	
	
	
