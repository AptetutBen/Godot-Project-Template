class_name Player extends CharacterBody3D

@export var speed : float = 7.0
@export var gravity : float = 9.8

@onready var camera_pivot: FollowCamera = %"Camera"
@onready var notification_marker: Marker3D = %NotificationMarker

var enabled : bool = true
var current_interact_object : InteractObject

func _ready() -> void:
	EventBus.enter_interact_object.connect(_on_enter_interact_object)
	EventBus.exit_interact_object.connect(_on_exit_interact_object)
	EventBus.start_conversation.connect(_on_start_conversation)
	EventBus.finish_conversation.connect(_on_finish_conversation)
	
func _physics_process(delta):
	_move(delta)

func _move(_delta : float):
	var camera_angle = camera_pivot.rotation.y
	var input = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	
	input = input.rotated(-camera_angle)
	
	if enabled:
		velocity.x = input.x * speed
		velocity.z = input.y * speed

	if !is_on_floor():
		velocity.y += -gravity 

	move_and_slide()
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

func _on_start_conversation():
	velocity = Vector3.ZERO
	enabled = false
	
func _on_finish_conversation():
	enabled = true
