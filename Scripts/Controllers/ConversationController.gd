class_name ConversationController extends Control

@onready var main_text: RichTextLabel = %"Main Text"
@onready var speaker_name_text: RichTextLabel = %"Speaker Name Text"
@onready var input_prompt_image: ColorRect = %"Input Prompt Image"

var skipText : bool

func _ready() -> void:
	EventBus.start_conversation.connect(_on_start_conversation)
	EventBus.finish_conversation.connect(_on_finish_conversation)

func display_text(text:String):
	input_prompt_image.visible = false
	main_text.text = text
	
	main_text.visible_characters = 0
	await get_tree().create_timer(1).timeout
	await get_tree().process_frame
	skipText = false
	for i in text.length():
		main_text.visible_characters = i+1
		if skipText:
			print("don't show this")
			main_text.visible_characters = -1
			break
		await get_tree().create_timer(0.01).timeout
	input_prompt_image.visible = true
	
	skipText = false
	while (!skipText):
		await get_tree().process_frame
	visible = false
	EventBus.finish_conversation.emit()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("UI Accept") || event.is_action_pressed("Interact"):
		skipText = true
	
func _on_start_conversation():
	display_text("This is a test asdf asdf asdf asdf asdf asdf ds f")
	visible = true

func _on_finish_conversation():
	visible = false
