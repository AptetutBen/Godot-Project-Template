extends Node

const gameSaveFileName : String = "game_data.save"
const gameSettingFileName : String = "game_setting.save"

var resizeTimer : Timer

# Default stored values
var default_save_data = {
	"value1" : 1,
	"value2" : 2,
	"value3" : 3
}

var game_settings_save_data = {
	"vsync" : "true",
	"fullscreen" : "false",
	"window_size" : "Vector2i(1920,1080)"
}

func get_is_vsync() -> bool:
	return str_to_var(game_settings_save_data["vsync"])

func set_vsync(value : bool) -> void:
	game_settings_save_data["vsync"] = var_to_str(value)
	_save_settings_data()

func get_is_fullscreen() -> bool:
	return str_to_var(game_settings_save_data["fullscreen"])

func set_fullscreen(value : bool) -> void:
	game_settings_save_data["fullscreen"] = var_to_str(value)
	_save_settings_data()

func get_resolution() -> Vector2i:
	return str_to_var(game_settings_save_data["window_size"])

func _set_window_size() -> void:
	if resizeTimer == null:
		resizeTimer = Timer.new()
		add_child(resizeTimer)
		resizeTimer.one_shot = true
		resizeTimer.timeout.connect(_on_view_port_resize_timer_timeout)
		resizeTimer.start(2)
	else:
		resizeTimer.start(2)
		

func _on_view_port_resize_timer_timeout():
	game_settings_save_data["window_size"] = var_to_str(DisplayServer.window_get_size())
	_save_settings_data()
	print("Updating window size")
	resizeTimer = null

# Current stored values
var save_data

# Init
func _init():
	_load_data()
	
func _ready() -> void:
	get_tree().get_root().size_changed.connect(_set_window_size)


func set_value1(value : int, doSave = true):
	save_data["value1"] = value
	if doSave:
		_save_data()

func get_value1() -> int:
	return save_data["value1"]

func set_value2(value : int, doSave = true):
	save_data["value2"] = value
	if doSave:
		_save_data()
		
func get_value2() -> int:
	return save_data["value2"]

func set_value3(value : int, doSave = true):
	save_data["value3"] = value
	if doSave:
		_save_data()
		
func get_value3() -> int:
	return save_data["value3"]

# Save data from save file
func _save_data():
	var json_string = JSON.stringify(save_data)
	var save_file = FileAccess.open("user://game_data.save", FileAccess.WRITE)
	save_file.store_line(json_string)
	save_file.close()

# Load data from save file
func _load_data():
	var save_file : FileAccess = FileAccess.open("user://game_data.save", FileAccess.READ)
	
	if save_file == null:
		save_data = default_save_data
		print("No audio save file, loading default values")
		return

	save_data = JSON.parse_string(save_file.get_as_text())

# Load data from save file
func _load_settings_data():
	var save_file : FileAccess = FileAccess.open("user://" + gameSettingFileName, FileAccess.READ)
	
	if save_file == null:
		_save_settings_data();
		return

	game_settings_save_data = JSON.parse_string(save_file.get_as_text())

func _save_settings_data():
	var json_string = JSON.stringify(game_settings_save_data)
	var save_file = FileAccess.open("user://" + gameSettingFileName, FileAccess.WRITE)
	save_file.store_line(json_string)
	save_file.close()

# Reset save data to default values
func clear_data():
	save_data = default_save_data
	_save_data()
