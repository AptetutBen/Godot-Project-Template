class_name GameController extends Node

static var Instance : GameController

@onready var intro_sequences: IntroSequences = %IntroSequences
@onready var camera: FollowCamera = %Camera
@onready var iris: Iris = %Iris
@onready var confirmation_panel: ConfirmationPanel = %ConfirmationPanel

@onready var road_block_parent: Node3D = $"Road Blocks"

@export var _use_debug : bool = false
@export var _debug_open_roadblocks : bool = false

var road_blocks : Array[RoadBlock]

func _ready() -> void:
	
	Instance = self
	
	# Check for debug
	if !OS.has_feature("editor"):
		_use_debug = false;
	
	_get_roadbloacks()
	_start_sequence()
	
func _start_sequence() -> void:

	if !FlowController.started_from_main_menu:
		intro_sequences.start_default()
	else:
		intro_sequences.start_intro_sequence()
	
func _get_roadbloacks() -> void:
	for node in road_block_parent.get_children():
		if node is RoadBlock:
			road_blocks.append(node)
	
	if _use_debug && _debug_open_roadblocks:
		for road_block in road_blocks:
			road_block.queue_free()
