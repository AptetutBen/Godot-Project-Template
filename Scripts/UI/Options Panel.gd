class_name Options extends Node

# Audio
#@onready var masterSlider: HSlider = $"TabContainer/Audio/Master Volume Slider"
#@onready var musicSlider: HSlider = $"TabContainer/Audio/Music Volume Slider"
#@onready var sfxSlider: HSlider = $"TabContainer/Audio/SFX Volume Slider"

# Graphics
#@onready var vsync_check_box: CheckBox = %"Vsync CheckBox"
#@onready var fullscreen_check_box: CheckBox = %"Fullscreen CheckBox"
#@onready var resolution_dropdown: OptionButton = %ResolutionDropdown

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#masterSlider.set_value_no_signal(AudioManager.get_master_volume())
	#musicSlider.set_value_no_signal(AudioManager.get_music_volume())
	#sfxSlider.set_value_no_signal(AudioManager.get_sfx_volume())
	#
	#vsync_check_box.set_pressed_no_signal(SaveController.get_is_vsync())
	#fullscreen_check_box.set_pressed_no_signal(SaveController.get_is_fullscreen())
	#resolution_dropdown.select(resolution_dropdown.get_item_index(640480))
	#resolution_dropdown.selected = resolution_dropdown.get_item_index(SaveController.get_resolution_id())

func _on_master_volume_slider_value_changed(value):
	AudioManager.set_master_volume(value)

func _on_music_volume_slider_value_changed(value):
	AudioManager.set_music_volume(value)

func _on_sfx_volume_slider_value_changed(value):
	AudioManager.set_sfx_volume(value)

func _on_slider_drag_ended(value_changed):
	if(value_changed):
		AudioManager.play_sfx("click1")
		AudioManager.save_audio_settings()
	
# Store the resolution selected by the user. As this function is connected
# to the `resolution_changed` signal, this will be executed any time the
# users chooses a new resolution
func _on_UIResolutionSelector_resolution_changed(new_resolution: Vector2) -> void:
	SaveController.set_resolution(new_resolution)
	DisplayServer.window_set_size(SaveController.get_resolution())

# Store the fullscreen setting. This will be called any time the users toggles
# the UIFullScreenCheckbox
func _on_UIFullscreenCheckbox_toggled(is_button_pressed: bool) -> void:
	SaveController.set_fullscreen(is_button_pressed)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if SaveController.get_is_fullscreen() else DisplayServer.WINDOW_MODE_WINDOWED)

# Store the vsync seting. This will be called any time the users toggles
# the UIVSyncCheckbox
func _on_UIVsyncCheckbox_toggled(is_button_pressed: bool) -> void:
	SaveController.set_vsync(is_button_pressed)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if SaveController.get_is_vsync() else DisplayServer.VSYNC_DISABLED)
