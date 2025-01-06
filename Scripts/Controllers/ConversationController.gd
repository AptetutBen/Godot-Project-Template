class_name ConversationController extends Control

@onready var main_text: RichTextLabel = %"Main Text"
@onready var speaker_name_text: Label = %"Speaker Name Text"
@onready var input_prompt_image: TextureRect = %"Input Prompt Image"
@onready var main_text_panel: Control = %"Main Text Panel"

var input_pressed : bool
var current_node : DialogueConversationNodeData

var blinking_tween : Tween
var panel_hide_tween : Tween

func _ready() -> void:
	visible = false
	EventBus.start_conversation.connect(_on_start_conversation)
	EventBus.finish_conversation.connect(_on_finish_conversation)
	
	blinking_tween = create_tween()
	blinking_tween.stop()
	blinking_tween.set_loops()
	blinking_tween.tween_property(input_prompt_image,"visible",true,0)
	blinking_tween.tween_interval(0.5)
	blinking_tween.tween_property(input_prompt_image,"visible",false,0)
	blinking_tween.tween_interval(0.5)
	

	panel_hide_tween = create_tween()
	panel_hide_tween.stop()
	panel_hide_tween.tween_property(main_text_panel,"position:y",230,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	panel_hide_tween.parallel().tween_property(main_text_panel,"scale:y",0.2,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

func display_text():
	visible = true
	input_prompt_image.visible = false

	await  get_tree().process_frame
	var panel_show_tween = create_tween()
	panel_show_tween.tween_interval(0.1)
	panel_show_tween.tween_property(main_text_panel,"position",Vector2.ZERO,0)
	panel_show_tween.tween_interval(0.1)
	panel_show_tween.tween_property(main_text_panel,"scale:x",2,0.1)
	panel_show_tween.parallel().tween_property(main_text_panel,"scale",Vector2.ONE,2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await panel_show_tween.finished
	
	while (true):
		main_text.visible_characters = 0
		main_text.text = current_node.text
		input_pressed = false
		for i in main_text.text.length():
			main_text.visible_characters = i+1
			if main_text.text[i] != " ":
				AudioManager.play_sfx("Key Tap",0.2,randf_range(0.8,1.2))
			if input_pressed:
				main_text.visible_characters = -1
				break
			await get_tree().create_timer(0.01).timeout
		
		blinking_tween.play()
		input_pressed = false
		while (!input_pressed):
			await get_tree().process_frame
		blinking_tween.stop()
		
		current_node = current_node.dialoge_data.get_next_node(current_node,0)
		if current_node == null:
			break
		
	panel_hide_tween.play()
	await panel_hide_tween.finished
	
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
