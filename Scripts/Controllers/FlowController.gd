extends Node

var currentScene = null
var sceneDirectory = {}

var active_pause_panel : Node
var started_from_main_menu : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().root
	currentScene = root.get_child(root.get_child_count() - 1)
	
	dir_contents("res://")
	#dir_contents_check("res://")
	
	SaveController._load_settings_data()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if SaveController.get_is_fullscreen() else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if SaveController.get_is_vsync() else DisplayServer.VSYNC_DISABLED)
	
	var window_size : Vector2i = SaveController.get_resolution()
	DisplayServer.window_set_size(window_size)
	
	var screen_size : Vector2i = DisplayServer.screen_get_size()
	var centered = Vector2(screen_size.x / 2 - window_size.x / 2, screen_size.y / 2 - window_size.y / 2)
	DisplayServer.window_set_position(centered)

func start_game() -> void:
	started_from_main_menu = true
	active_pause_panel = null
	var time_till_next_day : float = SaveController.get_time_till_next_day()
	if(time_till_next_day > 0):
		SaveController.advance_current_day()
		SaveController.set_last_played_time()
		SaveController.save_data()
		SaveController.get_etheral_value_bool("is_start_of_day",true)
	load_scene("Game")
	
func end_day():
	SaveController.advance_current_day()
	SaveController.get_etheral_value_bool("is_start_of_day",false)
	load_main_menu()

# Pausing the game
func pause_game(active_panel : Node = null) -> void:
	active_pause_panel = active_panel
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false
	active_pause_panel = null

func panel_can_work(panel : Node) -> bool:
	return active_pause_panel == null || active_pause_panel == panel

func load_main_menu():
	load_scene("Main Menu")

func load_scene(scene_name):
	get_tree().paused = false
	call_deferred("_deferred_goto_scene", scene_name)

func _deferred_goto_scene(scene_name):
	
	if !sceneDirectory.has(scene_name):
		print("** Error ** Can't find scene: " + scene_name)
		return
		
	# It is now safe to remove the current scene.
	currentScene.free()

	# Load the new scene.
	var s = ResourceLoader.load(sceneDirectory[scene_name])

	# Instance the new scene.
	currentScene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(currentScene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = currentScene
	
func dir_contents(path):
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# Recursively call dir_contents for subdirectories
				dir_contents(path + "/" + file_name)
			else:
				if file_name.get_extension() == "remap":
					file_name = file_name.left(len(file_name) - len('.remap'))
				if file_name.get_extension().to_lower() == "tscn":
					sceneDirectory[file_name.substr(0,file_name.length()-len(".tscn"))] = path + "/" + file_name
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
