extends GraphNode

@onready var text_edit: TextEdit = %TextEdit
@onready var preview_text: RichTextLabel = %"Preview Text"
@onready var editor_group: VBoxContainer = %"Editor Group"
@onready var minimise_button: Button = %"Minimise Button"
@onready var maximise_button: Button = %MaximiseButton

var dialogeNodeData : DisalogueData

var textLines : Array[String]

func initiliase(data : DisalogueData):
	dialogeNodeData = data
	position = dialogeNodeData.position
	text_edit.text = dialogeNodeData.text
	preview_text.text = text_edit.text

func save_node() -> void:
	dialogeNodeData.position = position
	dialogeNodeData.text = text_edit.text

func _on_delete_request() -> void:
	print("Delete Request")

func _on_dragged(from: Vector2, to: Vector2) -> void:
	print("Dragged")
	
func _on_text_changed() -> void:
	preview_text.text = text_edit.text

func _on_minimise_button_press():
	minimise_button.visible = false
	maximise_button.visible = true
	editor_group.visible = false
	size = Vector2(size.x,180)

func _on_maximise_button_press():
	editor_group.visible = true
	minimise_button.visible = true
	maximise_button.visible = false
	size = Vector2(size.x,320)

func _on_bold_button_press():
	_add_markup("[b]","[/b]")

func _on_italic_button_press():
	_add_markup("[i]","[/i]")

func _on_underline_button_press():
	_add_markup("[u]","[/u]")

func _on_wave_button_press():
	_add_markup("[wave amp=50.0 freq=5.0 connected=1]","[/wave]")

func _on_tornado_button_press():
	_add_markup("[tornado radius=5 freq=2]","[/tornado]")

func _on_shake_button_press():
	_add_markup("[shake rate=5 level=10]","[/shake]")

func _on_fade_button_press():
	_add_markup("[fade start=4 length=14]","[/fade]")

func _on_rainbow_button_press():
	_add_markup("[rainbow freq=0.2 sat=10 val=20]","[/rainbow]")

func _on_colour_button_press():
	_add_markup("[b]","[/b]")
	
	#var selectedText : String = text_edit.get_selected_text()
	#
	#if selectedText.contains("[/b]"):
		#selectedText.replace("[/b]","")
	#
	#if selectedText.contains("[b]"):
		#selectedText.replace("[b]","")
	#
	#var string_array = PackedStringArray(textLines)
	#var fullOldString = "".join(string_array)
	#var newString : String = fullOldString.substr(0,startSelectionPos) + selectedText + fullOldString.substr(endSelectionPos,-1) 
#
	#text_edit.text = newString
	


func _add_markup(start : String, end : String):
	var selectionLinefrom : int = text_edit.get_selection_from_line()
	var selectionColumnfrom : int = text_edit.get_selection_from_column()
	
	var selectionLineTo : int = text_edit.get_selection_to_line()
	var selectionColumnTo : int = text_edit.get_selection_to_column()

	text_edit.insert_text(end,selectionLineTo,selectionColumnTo)
	text_edit.insert_text(start,selectionLinefrom,selectionColumnfrom)
	text_edit.get_selected_text()
	
	textLines.clear()

	for i in text_edit.get_line_count():
		textLines.append(text_edit.get_line(i))
	
	var startSelectionPos : int = _get_string_position(selectionLinefrom,selectionColumnfrom)
	var endSelectionPos : int = _get_string_position(selectionLineTo,selectionColumnTo)
	print("Start Selection: " + str(startSelectionPos))
	print("End Selection: " + str(endSelectionPos))

func _get_string_position(line:int, column:int):
	var counter : int =0
	
	for i in line:
		counter += textLines[i].length()
	
	return counter + column
		
