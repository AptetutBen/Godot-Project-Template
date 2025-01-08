extends Control

@export var player: Player
@onready var notification_icon: Control = %Notification
@onready var notivication_pivot: Node2D = %"Notivication Pivot"

var current_tween : Tween

func _ready() -> void:
	visible = true
	player.interact_change.connect(_on_interact_change)
	notification_icon.visible = false;

func _process(_delta: float) -> void:
	
	if !notification_icon.is_visible_in_tree():
		return
	
	var notification_pos = FollowCamera.Instance.main_camera.unproject_position(player.notification_marker.global_position)
	notification_icon.position = notification_pos

func _on_interact_change(has_interact : bool):
	if has_interact:
		_on_enter_interact_object()
	else:
		_on_exit_interact_object()

func _on_enter_interact_object():
	if notification_icon.visible:
		return
	notification_icon.visible = true;
	
	if current_tween != null:
		current_tween.kill()
	
	notivication_pivot.scale = Vector2.ZERO
	current_tween = create_tween()
	current_tween.tween_property(notivication_pivot,"scale:y",1,0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	current_tween.parallel().tween_property(notivication_pivot,"scale:x",1,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _on_exit_interact_object():

	if current_tween != null:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.tween_property(notivication_pivot,"scale",Vector2.ZERO,0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	current_tween.tween_callback(func (): notification_icon.visible = false)
