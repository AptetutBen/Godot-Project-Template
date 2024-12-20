extends Control

@export var player: Player
@onready var notification: Control = %Notification

var current_interact_object : InteractObject

func _ready() -> void:
	EventBus.enter_interact_object.connect(_on_enter_interact_object)
	EventBus.exit_interact_object.connect(_on_exit_interact_object)
	notification.visible = false;

func _process(delta: float) -> void:
	
	if !notification.is_visible_in_tree():
		return
	
	var notification_pos = get_viewport().get_camera_3d().unproject_position(player.notification_marker.global_position)
	notification.position = notification_pos

func _on_enter_interact_object(interact_object:InteractObject):
	current_interact_object = interact_object
	notification.visible = true;

func _on_exit_interact_object(interact_object:InteractObject):
	if current_interact_object != interact_object:
		return
	notification.visible = false;
	current_interact_object = null
