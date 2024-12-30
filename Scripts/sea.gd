@tool
extends Node3D

@export var min_height : float = 0.25 
@export var max_height : float = 0.3
@export var speed : float = 0.1

var temp_timer : float = 0;

func _process(delta: float) -> void:
	temp_timer += delta;
	
	RenderingServer.global_shader_parameter_set("sea_value", temp_timer)
	
	var value : float = (sin(temp_timer * speed)* 2) - 1
	
	position.y = lerp(min_height,max_height,value)
	
