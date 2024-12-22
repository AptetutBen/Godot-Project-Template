class_name Pickup extends Node3D

@onready var area_3d: InteractObject = %Area3D

func _ready() -> void:
	area_3d.interact_signal.connect(interact)
	

func interact():
	EventBus.pickup_object.emit(self)
	queue_free()
