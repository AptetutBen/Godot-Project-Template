class_name FollowCamera extends Node3D

static var Instance : FollowCamera
@export var deadzone_margin_x: float = 40
@export var deadzone_margin_y: float = 40
@export var default_offset: Vector3 = Vector3(0,14,14)

@export var follow_speed: float = 5.0 # Camera follow speed

@export var player: Player
@export var debug : bool = false

@onready var debug_viewer: Control = %"Debug Viewer"
@onready var main_camera: Camera3D = %"Main Camera"
@onready var camera_target: Marker3D = %"Camera Target"

var deadzone_rect : Rect2
var player_screen_pos : Vector2
var player_nav_pos : Vector2
var player_nav_slide_position : Vector2
var closest_player_screen_pos : Vector2
var player_in_deadzone : bool
var target_camera_position : Vector3

var transition_tween : Tween
var camera_tween_is_active : bool = false
var camera_hijacked : bool = false
var current_camera_zone : CameraZone

func _ready() -> void:
	Instance = self
	EventBus.enter_camera_zone.connect(_on_camera_zone_enter)
	EventBus.exit_camera_zone.connect(_on_camera_zone_exit)
	EventBus.start_conversation.connect(_on_start_conversation)
	EventBus.finish_conversation.connect(_on_finish_conversation)
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	_on_window_size_changed()
	
	debug_viewer.visible = debug

func set_default_start() -> void:
	main_camera.look_at(camera_target.global_position)
	position = player.position


func _process(delta: float) -> void:
	if camera_hijacked:
		return
	
	if camera_tween_is_active:
		var xform : Transform3D = main_camera.transform
		xform = xform.looking_at(camera_target.position)
		main_camera.transform = main_camera.transform.interpolate_with(xform,delta * 3)
		
func _on_window_size_changed():
	# Calculate the screen-space position of the camera's deadzone
	var viewport_size : Vector2i = get_viewport().get_visible_rect().size
	deadzone_rect.size.x = viewport_size.x - (2 * deadzone_margin_x)
	deadzone_rect.size.y = viewport_size.y - (2 * deadzone_margin_y)
	deadzone_rect.position.x = deadzone_margin_x
	deadzone_rect.position.y = deadzone_margin_y

func _physics_process(delta):
	var distance : float = (position-target_camera_position).length()
	position = position.move_toward(target_camera_position,distance * 2 * delta)
	
	if !player:
		return
	
	if camera_hijacked:
		return
		
	# Convert player world position to screen space
	player_screen_pos = get_viewport().get_camera_3d().unproject_position(player.global_transform.origin + camera_target.position)
	player_in_deadzone = deadzone_rect.has_point(player_screen_pos)
	
	if !player_in_deadzone:
		
		closest_player_screen_pos = Vector2(
			clamp(player_screen_pos.x, deadzone_rect.position.x, deadzone_rect.position.x + deadzone_rect.size.x),
			clamp(player_screen_pos.y, deadzone_rect.position.y, deadzone_rect.position.y + deadzone_rect.size.y)
		)
		
		target_camera_position = player.position

		#var distance : float = (closest_player_screen_pos-player_screen_pos).length()
		#
		#position = position.move_toward(player.position,distance * 0.2 * delta)
	
func _on_start_conversation(_dialogue_node, node : Node3D):
	camera_hijacked = true
	var camera_angle_degrees : float = (node.global_position - player.global_position).normalized().angle_to(Vector3(0,0,-1)) * 180 / PI
	var center_pos : Vector3 = player.global_position - (player.global_position - node.global_position) / 2
	_transition_to_point(Vector3(0,3,5),center_pos,camera_angle_degrees,1,Tween.TRANS_SINE)
	
func _on_finish_conversation():
	target_camera_position = player.position
	camera_hijacked = false
	if current_camera_zone:
		_transition(current_camera_zone.offset,current_camera_zone.angle,1,Tween.TRANS_SINE)
	else:
		_transition(default_offset,0,1,Tween.TRANS_SINE)
	
func _transition(offset : Vector3, angle: float = 0, duration : float = 5, ease_type: Tween.TransitionType = Tween.TRANS_CUBIC):
	if camera_hijacked:
		return
	if transition_tween:
		transition_tween.kill()
	camera_tween_is_active = true
	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(main_camera, "position", offset, duration).set_ease(Tween.EASE_IN_OUT).set_trans(ease_type)
	transition_tween.parallel().tween_property(self, "rotation_degrees", Vector3(0,angle,0), duration).set_ease(Tween.EASE_IN_OUT).set_trans(ease_type)
	transition_tween.tween_callback(_stop_tween)
	transition_tween.play()

func _transition_to_point(offset : Vector3, focus_posion : Vector3 , angle: float = 0, duration : float = 5, ease_type: Tween.TransitionType = Tween.TRANS_CUBIC):
	if camera_hijacked:
		return
	if transition_tween:
		transition_tween.kill()
	
	target_camera_position = focus_posion
	camera_tween_is_active = true
	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(main_camera, "position", offset, duration).set_ease(Tween.EASE_IN_OUT).set_trans(ease_type)
	transition_tween.parallel().tween_property(self, "rotation_degrees", Vector3(0,angle,0), duration).set_ease(Tween.EASE_IN_OUT).set_trans(ease_type)
	transition_tween.tween_callback(_stop_tween)
	transition_tween.play()

func _stop_tween():
	camera_tween_is_active = false

func _on_camera_zone_enter(zone : CameraZone):
	current_camera_zone = zone
	if camera_hijacked:
		return
	_transition(zone.offset,zone.angle)

func _on_camera_zone_exit(zone : CameraZone):
	if camera_hijacked:
		return
	if(zone != current_camera_zone):
		return
	current_camera_zone = null
	_transition(default_offset,0)

func start_day_sequence(marker : Marker3D) -> void:
	camera_hijacked = true
	#target_camera_position = marker.position
	main_camera.position = marker.position
	main_camera.rotation = marker.rotation

func end_day_sequence() -> void:
	camera_hijacked = false
	target_camera_position = player.position
	if(current_camera_zone):
		_transition(current_camera_zone.offset,current_camera_zone.angle)
	else:
		_transition(default_offset,0)
