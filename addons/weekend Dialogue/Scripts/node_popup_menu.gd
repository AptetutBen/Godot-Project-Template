extends PopupMenu

var selected_node : DialogueNode

func _ready() -> void:
	hide()

func show_popup(node : DialogueNode) -> void:
	print(node.name)
	selected_node = node
	visible = true
	position = node.global_position

func _on_delete_button_press():
	selected_node._on_delete_request()
	hide()
