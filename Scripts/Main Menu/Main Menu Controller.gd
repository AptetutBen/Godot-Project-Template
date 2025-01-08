extends Control

var controlPanel 
@onready var credits: TextureRect = %Credits

func _ready():
	AudioManager.play_music("Main Menu Music")
	controlPanel = get_node("Options Panel")
	controlPanel.hide()
	credits.hide()

func _on_start_button_pressed():
	FlowController.start_game()
	AudioManager.play_sfx("click1")

func _on_exit_button_pressed():
	AudioManager.play_sfx("click1")
	get_tree().quit()

func _on_credits_button_pressed():
	AudioManager.play_sfx("click1")
	credits.visible = true

func _on_close_credits_button_pressed():
	AudioManager.play_sfx("click1")
	credits.visible = true

func _on_options_button_pressed():
	AudioManager.play_sfx("click1")
	controlPanel.show()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			handle_escape_key_pressed()

func handle_escape_key_pressed():
	controlPanel.hide()
