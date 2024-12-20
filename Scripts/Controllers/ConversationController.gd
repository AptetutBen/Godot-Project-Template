class_name ConversationController extends Control

@onready var main_text: RichTextLabel = %"Main Text"
@onready var speaker_name_text: RichTextLabel = %"Speaker Name Text"
@onready var input_prompt_image: ColorRect = %"Input Prompt Image"

var skipText : bool

func _ready() -> void:
	display_text("This is a test asdf asdf asdf asdf asdf asdf ds f")

func display_text(text:String):
	input_prompt_image.visible = false
	main_text.text = text
	skipText = false
	
	for i in text.length():
		main_text.visible_characters = i+1
		if skipText:
			main_text.visible_characters = -1
			break
		await get_tree().create_timer(0.01).timeout
	input_prompt_image.visible = true
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("UI Accept") || event.is_action_pressed("Left Click"):
		skipText = true
		
	
