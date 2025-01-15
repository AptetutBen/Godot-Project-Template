extends Control

var controlPanel 
@onready var credits: Credits = %Credits
@onready var version_label: Label = $"Version Label"

@onready var main_buttons: TextButtonGroup = %"Main Buttons"
@onready var options_buttons: TextButtonGroup = %"Options Buttons"

func _ready():
	AudioManager.play_music("Main Menu Music")
	controlPanel = get_node("Options Panel")
	controlPanel.hide()
	credits.hide()
	options_buttons.hide()
	main_buttons.show()
	version_label.text = "v " + ProjectSettings.get_setting("application/config/version")

func _on_start_button_pressed():
	FlowController.start_game()
	AudioManager.play_sfx("click1")

func _on_exit_button_pressed():
	AudioManager.play_sfx("click1")
	get_tree().quit()

func _on_credits_button_pressed():
	AudioManager.play_sfx("click1")
	credits.show_panel()
	main_buttons.disable()

func _on_close_credits_button_pressed():
	AudioManager.play_sfx("click1")
	credits.hide_panel()
	main_buttons.enable()

func _on_options_button_pressed():
	AudioManager.play_sfx("click1")
	options_buttons.enable()
	main_buttons.disable()

#func _input(event):
	#if event.is_action_pressed("UI Cancel"):
		#_on_back_button_button_action()

func _on_back_button_button_action() -> void:
	AudioManager.play_sfx("click1")
	options_buttons.disable(true)
	main_buttons.enable()
