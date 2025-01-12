extends Node

@onready var tent: StaticBody3D = %Tent
@onready var build_point: Area3D = %"Build Point"
@onready var post_build_marker: Marker3D = $"Post Build Marker"


func _ready() -> void:
	if SaveController.has_variable("camp_setup"):
		tent.process_mode = Node.PROCESS_MODE_INHERIT
		tent.visible = true
		build_point.visible = false
	else:
		tent.visible = false
		tent.process_mode = Node.PROCESS_MODE_DISABLED
		build_point.visible = true

func build_camp() -> void:
	
	EventBus.enable_player.emit(false)
	await GameController.Instance.iris.iris_in()

	tent.process_mode = Node.PROCESS_MODE_INHERIT
	tent.visible = true
	build_point.visible = false
	Player.Instance.global_position = post_build_marker.global_position
	
	# play sound
	
	await GameController.Instance.iris.iris_out()

	SaveController.set_value_bool("camp_setup",true)
	EventBus.enable_player.emit(true)
