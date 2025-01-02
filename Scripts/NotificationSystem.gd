extends Control

@export var player: Player
@onready var notification_icon: Control = %Notification

var current_interact_object : InteractObject

func _ready() -> void:
	visible = true
	EventBus.enter_interact_object.connect(_on_enter_interact_object)
	EventBus.exit_interact_object.connect(_on_exit_interact_object)
	notification_icon.visible = false;

func _process(_delta: float) -> void:
	
	if !notification_icon.is_visible_in_tree():
		return
	
	var notification_pos = FollowCamera.Instance.main_camera.unproject_position(player.notification_marker.global_position)
	notification_icon.position = notification_pos

func _on_enter_interact_object(interact_object:InteractObject):
	current_interact_object = interact_object
	notification_icon.visible = true;

func _on_exit_interact_object(interact_object:InteractObject):
	if current_interact_object != interact_object:
		return
	notification_icon.visible = false;
	current_interact_object = null
