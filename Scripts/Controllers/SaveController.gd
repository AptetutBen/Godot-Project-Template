extends Node

const time_between_days : float = 240 # 4 hours
const gameSaveFileName : String = "game_data.save"
const gameSettingFileName : String = "game_setting.save"

const current_day_key : String = "current_day"
const last_played_time_key : String = "last_played_time"

var resizeTimer : Timer

# Current stored values
var variable_dictionary = {}
var ethereal_dictionary = {}

# Init
func _init():
	_load_data()
	
func _ready() -> void:
	get_tree().get_root().size_changed.connect(_set_window_size)

func reset_save_data() -> void:
	variable_dictionary.clear()
	save_data()
	
func clear_etheral_data() -> void:
	ethereal_dictionary.clear()

# Save Data

func get_value(key : String, default : String = "default") -> String:
	return variable_dictionary.get(key,default)

func set_value(key : String, value : String) -> void:
	variable_dictionary.set(key,value)

func get_value_int(key : String, default : int) -> int:
	return variable_dictionary.get(key,default)

func set_value_int(key : String, value : int) -> void:
	variable_dictionary.set(key,value)

func get_value_float(key : String, default : float) -> float:
	return variable_dictionary.get(key,default)

func set_value_float(key : String, value : float) -> void:
	variable_dictionary.set(key,value)
	
func get_value_bool(key : String, default : bool) -> bool:
	return variable_dictionary.get(key,default)
	
func has_variable(key : String) -> bool:
	return variable_dictionary.has(key)
	
func is_true(key : String) -> bool:
	return variable_dictionary.get(key, false)

func is_value(key : String, value) -> bool:
	return variable_dictionary.get(key,"") == value

# Etherial Data

func get_etheral_value(key : String, default : String = "default") -> String:
	return ethereal_dictionary.get(key,default)

func set_etheral_value(key : String, value : String) -> void:
	ethereal_dictionary.set(key,value)

func get_etheral_value_int(key : String, default : int) -> int:
	return ethereal_dictionary.get(key,default)

func set_etheral_value_int(key : String, value : int) -> void:
	ethereal_dictionary.set(key,value)

func get_etheral_value_float(key : String, default : float) -> float:
	return ethereal_dictionary.get(key,default)

func set_etheral_value_float(key : String, value : float) -> void:
	ethereal_dictionary.set(key,value)
	
func get_etheral_value_bool(key : String, default : bool) -> bool:
	return ethereal_dictionary.get(key,default)
	
func has_etheral_variable(key : String) -> bool:
	return ethereal_dictionary.has(key)
	
func is_etheral_true(key : String) -> bool:
	return ethereal_dictionary.get(key, false)

func is_etheral_value(key : String, value) -> bool:
	return ethereal_dictionary.get(key,"") == value

# Game Settings

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


# Time
func get_last_since_last_played() -> float:
	var last_played_time : float = get_value_float(last_played_time_key,999999)
	var current_time : float = Time.get_unix_time_from_system()
	return current_time - last_played_time

func get_time_till_next_day() -> float:
	return time_between_days - get_last_since_last_played()

func set_last_played_time() -> void:
	set_value_float(last_played_time_key,Time.get_unix_time_from_system())

# Day

func advance_current_day():
	set_value_int(current_day_key,get_current_day() +1)
		
func get_current_day() -> int:
	return get_value_int(current_day_key,-1)

# Save data from save file
func save_data():
	var json_string = JSON.stringify(variable_dictionary)
	var save_file = FileAccess.open("user://%s"%[gameSaveFileName], FileAccess.WRITE)
	save_file.store_line(json_string)
	save_file.close()

# Load data from save file
func _load_data():
	var save_file : FileAccess = FileAccess.open("user://%s"%[gameSaveFileName], FileAccess.READ)
	
	if save_file == null:
		variable_dictionary = {}
		return

	variable_dictionary = JSON.parse_string(save_file.get_as_text())

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
