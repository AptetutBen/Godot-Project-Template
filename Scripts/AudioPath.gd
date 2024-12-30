extends Node3D

@onready var path_3d: Path3D = $Path3D
@onready var audio_stream_3d: AudioStreamPlayer3D = %AudioStreamPlayer3D
@export var player: Player

func _process(delta: float) -> void:
	var ls : Vector3 = path_3d.to_local(player.global_position)
	audio_stream_3d.position =  path_3d.curve.get_closest_point(ls)
