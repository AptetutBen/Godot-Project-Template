extends Node3D

@export var title : String
@export_multiline var text : String

func _on_interact():
	EventBus.start_display_message.emit(text.split("~"),title)
