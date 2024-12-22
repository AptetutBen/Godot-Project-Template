class_name ItemSpawnArea extends Node3D

@export var item_to_spawn : PackedScene


func _ready() -> void:
	
	var markers : Array[Node]
	markers = get_children() 
	markers.shuffle()
	
	for i in 4:
		var item : Node3D = item_to_spawn.instantiate()
		add_child(item)
		item.position = markers[i].position
		item.rotate_y(randf() * PI * 2)
