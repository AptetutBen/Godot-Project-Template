class_name TextButtonGroup extends Control

@export var buttons : Array[MenuText]
var selectedButtonIndex : int = 0
@export var vertical : bool = true
var active : bool = false
var can_navigate : bool = true

func _ready() -> void:
	active = false
	visibility_changed.connect(_on_visiblity_changed)
	for i in buttons.size():
		buttons[i].index = i 
		buttons[i].highlight_button.connect(select_button)
		buttons[i].on_click.connect(on_button_click)
	enable()

func _on_visiblity_changed() -> void:
	if !is_visible_in_tree():
		disable()
	else:
		enable()

func enable():
	active = true
	selectedButtonIndex = 0
	select_button(selectedButtonIndex,false)

func disable():
	select_button(-1,false)

func select_button(index : int, play_sound : bool = true):
	for i in buttons.size():
		if i == index:
			buttons[i].select_button()
		else:
			buttons[i].deselect_button()
	if play_sound:
		AudioManager.play_sfx("click1")

func on_button_click(button_index : int) -> void:
	AudioManager.play_sfx("click1")
	buttons[button_index].buttonAction.emit()
	active = false

func _input(event: InputEvent) -> void:
	if !is_visible_in_tree() || !active :
		return

	if event.is_action_pressed("UI Accept"):
		buttons[selectedButtonIndex].trigger_action()
	
	if event.is_action_pressed("UI Up" if vertical else "UI Left"):
		if !can_navigate:
			return
		AudioManager.play_sfx("click1")
		buttons[selectedButtonIndex].deselect_button()
		selectedButtonIndex -= 1
		if selectedButtonIndex < 0:
			selectedButtonIndex = buttons.size() - 1
		select_button(selectedButtonIndex)
		can_navigate = false
		await get_tree().create_timer(0.15).timeout
		can_navigate = true
	
	if event.is_action_pressed("UI Down" if vertical else "UI Right"):
		if !can_navigate:
			return
		AudioManager.play_sfx("click1")
		buttons[selectedButtonIndex].deselect_button()
		selectedButtonIndex += 1
		if selectedButtonIndex >= buttons.size():
			selectedButtonIndex = 0
		select_button(selectedButtonIndex)
		can_navigate = false
		await get_tree().create_timer(0.05).timeout
		can_navigate = true
