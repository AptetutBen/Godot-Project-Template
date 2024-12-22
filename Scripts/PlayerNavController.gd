class_name PlayerNav extends CharacterBody3D

@export var speed : float = 7.0
@export var gravity : float = 9.8
@export var nav_tether_distance : float = 0.5

@onready var camera_pivot: FollowCamera = %"Camera Pivot"
@onready var notification_marker: Marker3D = %NotificationMarker

var closest_nav_point : Vector3
var closest_nav_point_normal : Vector3
var slide_vector : Vector3

var current_interact_object : InteractObject


func _ready() -> void:
	EventBus.enter_interact_object.connect(_on_enter_interact_object)
	EventBus.exit_interact_object.connect(_on_exit_interact_object)
	
func _physics_process(delta):
	_move(delta)

func _move(_delta : float):
	var camera_angle = camera_pivot.rotation.y
	var input = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")

	input = input.rotated(-camera_angle)
	
	var nav_slow_time : float = clamp(-(closest_nav_point - position).dot(Vector3(input.x,closest_nav_point.y,input.y )),0,nav_tether_distance)
	var speed_modifier = 1-nav_slow_time/nav_tether_distance
	
	velocity.x = input.x * speed * speed_modifier
	velocity.z = input.y * speed * speed_modifier

	if !is_on_floor():
		velocity.y += -gravity 

	move_and_slide()

	var nav_map = get_world_3d().navigation_map
	closest_nav_point = NavigationServer3D.map_get_closest_point(nav_map,position)
	
	# Get the normal of the edge
	closest_nav_point_normal = NavigationServer3D.map_get_closest_point_normal(nav_map, closest_nav_point)
	
	# Calculate sliding direction (tangent to the edge)
	slide_vector =  closest_nav_point_normal #velocity.cross(closest_nav_point_normal).cross(closest_nav_point).normalized()

	RenderingServer.global_shader_parameter_set("player_position", global_position)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") && current_interact_object != null:
		current_interact_object.interact()

func _on_enter_interact_object(interact_object:InteractObject):
	current_interact_object = interact_object

func _on_exit_interact_object(interact_object:InteractObject):
	if current_interact_object != interact_object:
		return
	current_interact_object = null
