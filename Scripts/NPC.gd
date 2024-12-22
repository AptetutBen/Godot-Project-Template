extends Node

@onready var area_3d: InteractObject = %Area3D

func _ready() -> void:
	area_3d.interact_signal.connect(_on_interact)
	EventBus.start_conversation.connect(_on_start_conversation)
	EventBus.finish_conversation.connect(_on_finish_conversation)

func _on_interact():
	EventBus.start_conversation.emit()
	
func _on_start_conversation():
	area_3d.monitoring = false

func _on_finish_conversation():
	area_3d.monitoring = true
