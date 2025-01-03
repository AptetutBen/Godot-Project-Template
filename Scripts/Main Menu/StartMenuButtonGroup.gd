extends Control

var buttons : Array[MenuText]
var selectedButtonIndex : int = 0
@export var vertical : bool = true
@export var active : bool = true

func _ready() -> void:
	for node: Node in get_children():
		buttons.append(node)
	buttons[selectedButtonIndex].select_button()
	
	for i in buttons.size():
		buttons[i].index = i
		buttons[i].onMouseClick.connect(on_button_click)

func on_button_click(button_index : int) -> void:
	AudioManager.play_sfx("click1")
	buttons[selectedButtonIndex].deselect_button()
	selectedButtonIndex = button_index
	buttons[selectedButtonIndex].select_button()
	buttons[selectedButtonIndex].trigger_action()

func _input(event: InputEvent) -> void:
	if !is_visible_in_tree() || !active :
		return

	if event.is_action_pressed("UI Accept"):
		buttons[selectedButtonIndex].trigger_action()
	
	if event.is_action_pressed("UI Up" if vertical else "UI Left"):
		AudioManager.play_sfx("click1")
		buttons[selectedButtonIndex].deselect_button()
		selectedButtonIndex -= 1
		if selectedButtonIndex < 0:
			selectedButtonIndex = buttons.size() - 1
		buttons[selectedButtonIndex].select_button()
	
	if event.is_action_pressed("UI Down" if vertical else "UI Right"):
		AudioManager.play_sfx("click1")
		buttons[selectedButtonIndex].deselect_button()
		selectedButtonIndex += 1
		if selectedButtonIndex >= buttons.size():
			selectedButtonIndex = 0
		buttons[selectedButtonIndex].select_button()
	
