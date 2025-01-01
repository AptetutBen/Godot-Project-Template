class_name ConversationController extends Control

@onready var main_text: RichTextLabel = %"Main Text"
@onready var speaker_name_text: RichTextLabel = %"Speaker Name Text"
@onready var input_prompt_image: ColorRect = %"Input Prompt Image"

var input_pressed : bool
var current_node : DialogueConversationNodeData

func _ready() -> void:
	EventBus.start_conversation.connect(_on_start_conversation)
	EventBus.finish_conversation.connect(_on_finish_conversation)

func display_text():
	
	await get_tree().create_timer(1).timeout
	while (true):
		input_prompt_image.visible = false
		main_text.visible_characters = 0
		main_text.text = current_node.text
		visible = true
		input_pressed = false
		for i in main_text.text.length():
			main_text.visible_characters = i+1
			if input_pressed:
				main_text.visible_characters = -1
				break
			await get_tree().create_timer(0.01).timeout
		input_prompt_image.visible = true
		
		input_pressed = false
		while (!input_pressed):
			await get_tree().process_frame
		
		current_node = current_node.dialoge_data.get_next_node(current_node,0)
		if current_node == null:
			break
		
	visible = false
	EventBus.finish_conversation.emit()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("UI Accept") || event.is_action_pressed("Interact"):
		input_pressed = true
	
func _on_start_conversation(dialogue_node : DialogueConversationNodeData, _node : Node3D):
	if dialogue_node == null:
		printerr("Conversatino is null")
		return
	current_node = dialogue_node
	display_text()


func _on_finish_conversation():
	visible = false
