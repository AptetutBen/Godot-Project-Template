class_name FollowCamera extends Camera3D

@export var deadzone_margin_x: float = 40
@export var deadzone_margin_y: float = 40

@export var follow_speed: float = 5.0 # Camera follow speed

@export var player: Player
@export var debug : bool = false
@onready var camera_pivot : Node3D = $".."

var deadzone_rect : Rect2
var player_screen_pos : Vector2
var closest_player_screen_pos : Vector2
var player_in_deadzone : bool

func _ready() -> void:
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	_on_window_size_changed()
	look_at(camera_pivot.position)

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
	player_screen_pos = get_viewport().get_camera_3d().unproject_position(player.global_transform.origin)
	player_in_deadzone = deadzone_rect.has_point(player_screen_pos)
	
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position,global_position - global_transform.basis.z * 500)
	var collision = space.intersect_ray(query)
	
	if !player_in_deadzone:
		
		closest_player_screen_pos = Vector2(
			clamp(player_screen_pos.x, deadzone_rect.position.x, deadzone_rect.position.x + deadzone_rect.size.x),
			clamp(player_screen_pos.y, deadzone_rect.position.y, deadzone_rect.position.y + deadzone_rect.size.y)
		)

		var distance : float = (closest_player_screen_pos-player_screen_pos).length()
		
		camera_pivot.position = camera_pivot.position.move_toward(player.position,distance * 0.2 * delta)
		#camera_pivot.position = lerp(camera_pivot.position,player.position, delta)
