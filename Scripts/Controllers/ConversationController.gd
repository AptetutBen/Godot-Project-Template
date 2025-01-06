class_name ConversationController extends Control

@onready var main_text: RichTextLabel = %"Main Text"
@onready var speaker_name_text: Label = %"Speaker Name Text"
@onready var input_prompt_image: TextureRect = %"Input Prompt Image"
@onready var pivot: Node2D = %Pivot

var input_pressed : bool
var current_node : DialogueConversationNodeData



func _ready() -> void:
	visible = false
	EventBus.start_conversation.connect(_on_start_conversation)
	EventBus.start_display_message.connect(_on_start_display_message)
	EventBus.finish_conversation.connect(_on_finish_conversation)

func display_conversation_text():
	speaker_name_text.visible = true
	await show_ui()
	while (true):
		await display_text(current_node.text)
		current_node = current_node.dialoge_data.get_next_node(current_node,0)
		if current_node == null:
			break
	
	await hide_ui()
	EventBus.finish_conversation.emit()

func display_message_text(textArray : Array[String], title : String):
	speaker_name_text.text = title
	speaker_name_text.visible = title != ""
	await show_ui()
	for text in textArray:
		await display_text(text)
	
	await hide_ui()
	EventBus.finish_conversation.emit()

func show_ui():
	visible = true
	input_prompt_image.visible = false
	main_text.visible_characters = 0
	pivot.scale = Vector2.ZERO
	pivot.position = Vector2.ZERO
	await  get_tree().process_frame
	var panel_show_tween = create_tween()
	panel_show_tween.tween_interval(0.1)
	panel_show_tween.tween_property(pivot,"scale:x",1,0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	panel_show_tween.parallel().tween_property(pivot,"scale:y",1,0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await panel_show_tween.finished

func hide_ui():
	var panel_hide_tween = create_tween()
	panel_hide_tween.tween_property(pivot,"position:y",230,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	panel_hide_tween.parallel().tween_property(pivot,"scale:y",0.5,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	panel_hide_tween.parallel().tween_property(pivot,"scale:x",0.8,0.4).set_delay(0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await panel_hide_tween.finished
	
	visible = false

func display_text(text : String):
	main_text.visible_characters = 0
	input_prompt_image.visible = false
	main_text.text = text
	input_pressed = false
	for i in main_text.text.length():
		main_text.visible_characters = i+1
		if main_text.text[i] != " ":
			AudioManager.play_sfx("Key Tap",0.2,randf_range(0.8,1.2))
		if input_pressed:
			main_text.visible_characters = -1
			break
		await get_tree().create_timer(0.01).timeout
	
	var blinking_tween = create_tween()
	blinking_tween.set_loops()
	blinking_tween.tween_property(input_prompt_image,"visible",true,0)
	blinking_tween.tween_interval(0.5)
	blinking_tween.tween_property(input_prompt_image,"visible",false,0)
	blinking_tween.tween_interval(0.5)

	input_pressed = false
	while (!input_pressed):
		await get_tree().process_frame
	blinking_tween.stop()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("UI Accept") || event.is_action_pressed("Interact"):
		input_pressed = true

func _on_start_display_message(textArray : Array[String], title: String):
	display_message_text(textArray,title)
	
func _on_start_conversation(dialogue_node : DialogueConversationNodeData, _node : Node3D):
	if dialogue_node == null:
		printerr("Conversatino is null")
		return
	current_node = dialogue_node
	display_conversation_text()


func _on_finish_conversation():
	visible = false
