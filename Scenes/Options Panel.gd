extends Panel

var masterSlider : HSlider;
var sfxSlider : HSlider;
var musicSlider : HSlider;

# Called when the node enters the scene tree for the first time.
func _ready():
	masterSlider = get_node("Master Volume Slider")
	sfxSlider = get_node("SFX Volume Slider")
	musicSlider = get_node("Music Volume Slider")

	masterSlider.value = AudioManager.get_master_volume()
	musicSlider.value = AudioManager.get_music_volume()
	sfxSlider.value = AudioManager.get_sfx_volume()

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


func _on_close_button_pressed():
	AudioManager.play_sfx("click1")
	hide()
