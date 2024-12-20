class_name Player extends CharacterBody3D

@export var speed : float = 10.0
@export var gravity : float = 9.8

@onready var notification_marker: Marker3D = %NotificationMarker

var current_interact_object : InteractObject

func _ready() -> void:
	EventBus.enter_interact_object.connect(_on_enter_interact_object)
	EventBus.exit_interact_object.connect(_on_exit_interact_object)
	
func _physics_process(delta):
	_move(delta)

func _move(delta : float):
	var input = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity.x = input.x * speed
	velocity.z = input.y * speed

	if !is_on_floor():
		velocity.y += -gravity * delta

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") && current_interact_object != null:
		current_interact_object.interact()

func _on_enter_interact_object(interact_object:InteractObject):
	current_interact_object = interact_object

func _on_exit_interact_object(interact_object:InteractObject):
	if current_interact_object != interact_object:
		return
	current_interact_object = null
