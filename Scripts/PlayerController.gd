class_name Player extends CharacterBody3D

static var Instance : Player

signal interact_change(_has_interact : bool)

@export var speed : float = 7.0
@export var run_speed : float = 10.0
@export var gravity : float = 9.8

@onready var camera_pivot: FollowCamera = %"Camera"
@onready var notification_marker: Marker3D = %NotificationMarker
@onready var animation_tree : AnimationTree = $"Mesh/AnimationTree"
@onready var mesh: Node3D = $Mesh

@export var grass_particles: Array[GPUParticles3D]
@export var sand_particles: Array[GPUParticles3D]
var particle_index : int =0

var is_running : bool = false
var enabled : bool = true
var current_interact_object : InteractObject
var input : Vector2

@export var terrain : Terrain3D

@export var footstep_distance : float = 2
var last_footstep_position : Vector3

# Sequence
var in_sequence : bool 
var sequence_target : Vector3
signal sequence_end

func _init() -> void:
	Instance = self
	
func _ready() -> void:
	EventBus.enter_interact_object.connect(_on_enter_interact_object)
	EventBus.exit_interact_object.connect(_on_exit_interact_object)
	EventBus.start_conversation.connect(_on_start_conversation)
	EventBus.finish_conversation.connect(_on_finish_conversation)
	EventBus.start_display_message.connect(_on_start_conversation)
	
	last_footstep_position = position
	
func _physics_process(delta):
	
	if in_sequence:
		_move_sequence()
	
	if !in_sequence:
		_move()
	
	_translate_player(delta)
	
func play_sequence(to_position : Vector3) -> void:
	in_sequence = true
	is_running = false
	sequence_target = to_position

func _move_sequence():
	var direction = (sequence_target - global_position).normalized()
	input = Vector2(direction.x,direction.z)
	if global_position.distance_to(sequence_target) < 0.5:
		in_sequence = false
		input = Vector2.ZERO
		sequence_end.emit()
	
func _move():
	if !enabled:
		return
		
	var camera_angle = camera_pivot.rotation.y
	input = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	input = input.rotated(-camera_angle)

func _input(event):
	
	if in_sequence || !enabled:
		return
		
	if event.is_action_pressed("Run"):
		is_running = true
	if event.is_action_released("Run"):
		is_running = false
	
	if event.is_action_pressed("Interact") && current_interact_object != null:
		current_interact_object.interact()
		current_interact_object = null
		interact_change.emit(false)

func _translate_player(delta : float):

	if input.length() > 0:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(input.x, input.y), 0.1)

	var move_multipliyer = 1
	
	if !in_sequence:
		move_multipliyer = clampf(1-(Sea.Height - global_position.y),0.2,1)
	
	input *= (speed if not is_running else run_speed) * move_multipliyer

	if !is_on_floor():
		velocity.y = velocity.y  -gravity * delta
	else:
		velocity.y = 0

	velocity.x = input.x
	velocity.z = input.y 
	
	animation_tree.set("parameters/speed/blend_position",velocity.length())

	move_and_slide()
	
	if position.distance_to(last_footstep_position) > footstep_distance:
		var texture_index : int 
		
		last_footstep_position = position
		var texture_data : Vector3 = terrain.data.get_texture_id(global_position)
		
		if texture_data == null:
			return
			
		if move_multipliyer< 1:
			texture_index = -1
		elif is_running:
			texture_index = texture_data[0] if texture_data[2] < 0.5 else texture_data[1]

			match texture_index:
				0:
					sand_particles[particle_index].restart()
				2:
					grass_particles[particle_index].restart()
				_:
					pass	
			
		AudioManager.play_footstep_sound(texture_index,1.0 if is_running else 0.5)
		
		particle_index = 0 if particle_index == 1 else 1
	
	#RenderingServer.global_shader_parameter_set("player_position", global_position)

func _on_enter_interact_object(interact_object:InteractObject):
	current_interact_object = interact_object
	interact_change.emit(true)

func _on_exit_interact_object(interact_object:InteractObject):
	if current_interact_object != interact_object:
		return
	current_interact_object = null
	interact_change.emit(false)

func _on_start_conversation(_dialogue_node, _node):
	input = Vector2.ZERO
	velocity = Vector3.ZERO
	animation_tree.set("parameters/speed/blend_position",0)
	enabled = false
	mesh.rotation_degrees.y = wrapf(mesh.rotation_degrees.y,-180,180)
	
	var turn_tween : Tween = get_tree().create_tween()
	var direction = (current_interact_object.global_transform.origin - global_transform.origin).normalized()
	var target_rotation_y = atan2(direction.x, direction.z)
	
	turn_tween.tween_property(mesh, "rotation_degrees", Vector3(0, rad_to_deg(target_rotation_y), 0), 0.5)
	turn_tween.set_ease(Tween.EASE_OUT_IN)
	turn_tween.set_trans(Tween.TRANS_SINE)
	
func _on_finish_conversation():
	is_running = false
	enabled = true
