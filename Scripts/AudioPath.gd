extends Node3D

@onready var path_3d: Path3D = $Path3D
@export var stream_player : AudioStreamPlayer3D

@export var player: Player

func _process(_delta: float) -> void:
	if !is_visible_in_tree():
		return
	var ls : Vector3 = path_3d.to_local(player.global_position)
	stream_player.position = path_3d.curve.get_closest_point(ls)
