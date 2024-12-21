class_name FollowCamera extends Node3D

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
var closest_player_screen_pos : Vector2
var player_in_deadzone : bool

var transition_tween : Tween
var camera_tween_is_active : bool = false

func _ready() -> void:
	EventBus.enter_camera_zone.connect(_on_camera_zone_enter)
	EventBus.exit_camera_zone.connect(_on_camera_zone_exit)
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	_on_window_size_changed()
	main_camera.look_at(camera_target.global_position)
	debug_viewer.visible = debug


func _process(_delta: float) -> void:
	if camera_tween_is_active:
		main_camera.look_at(camera_target.global_position)

func _on_window_size_changed():
	# Calculate the screen-space position of the camera's deadzone
	var viewport_size : Vector2i = get_viewport().get_visible_rect().size
	deadzone_rect.size.x = viewport_size.x - (2 * deadzone_margin_x)
	deadzone_rect.size.y = viewport_size.y - (2 * deadzone_margin_y)
	deadzone_rect.position.x = deadzone_margin_x
	deadzone_rect.position.y = deadzone_margin_y

func _physics_process(delta):
	if not player:
		return

	# Convert player world position to screen space
	player_screen_pos = get_viewport().get_camera_3d().unproject_position(player.global_transform.origin + camera_target.position)
	player_in_deadzone = deadzone_rect.has_point(player_screen_pos)
	
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position,global_position - global_transform.basis.z * 500)
	#var collision = space.intersect_ray(query)
	
	if !player_in_deadzone:
		
		closest_player_screen_pos = Vector2(
			clamp(player_screen_pos.x, deadzone_rect.position.x, deadzone_rect.position.x + deadzone_rect.size.x),
			clamp(player_screen_pos.y, deadzone_rect.position.y, deadzone_rect.position.y + deadzone_rect.size.y)
		)

		var distance : float = (closest_player_screen_pos-player_screen_pos).length()
		
		position = position.move_toward(player.position,distance * 0.2 * delta)
		#camera_pivot.position = lerp(camera_pivot.position,player.position, delta)

func _transition(offset : Vector3, angle: float = 0):
	if transition_tween:
		transition_tween.kill()
	camera_tween_is_active = true
	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(main_camera, "position", offset, 5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	transition_tween.parallel().tween_property(self, "rotation_degrees", Vector3(0,angle,0), 5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	transition_tween.tween_callback(_stop_tween)
	transition_tween.play()

func _stop_tween():
	camera_tween_is_active = false

func _on_camera_zone_enter(zone : CameraZone):
	_transition(zone.offset,zone.angle)

func _on_camera_zone_exit(zone : CameraZone):
	_transition(default_offset,0)
