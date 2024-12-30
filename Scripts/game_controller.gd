class_name GameController extends Node

var road_blocks : Array[RoadBlock]
@onready var road_block_parent: Node3D = $"Road Blocks"

@export var _use_debug : bool = false
@export var _debug_open_roadblocks : bool = false

func _ready() -> void:
	
	# Check for debug
	if !OS.has_feature("editor"):
		_use_debug = false;
	
	_get_roadbloacks()
	
	if _use_debug && _debug_open_roadblocks:
		for road_block in road_blocks:
			road_block.queue_free()

func _get_roadbloacks() -> void:
	for node in road_block_parent.get_children():
		if node is RoadBlock:
			road_blocks.append(node)
