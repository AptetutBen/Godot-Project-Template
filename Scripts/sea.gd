@tool
class_name Sea extends Node3D

static var Height : float
@export var min_height : float = 0.25 
@export var max_height : float = 0.3
@export var speed : float = 0.1
@export_range(-10,10) var wave_offset : float = 0.5

var temp_timer : float = 0;

func _process(delta: float) -> void:
	temp_timer += delta;
	
	RenderingServer.global_shader_parameter_set("sea_value", temp_timer + wave_offset)
	
	var value : float = (sin(temp_timer * speed)* 2) - 1
	
	Height = lerp(min_height,max_height,value)
	global_position.y = Height
	
