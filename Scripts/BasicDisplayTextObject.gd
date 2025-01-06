extends Node3D

@export var title : String
@export_multiline var text : String
@onready var interact: InteractObject = $"Interact Area"

func _ready() -> void:
	interact.interact_signal.connect(_on_interact)

func _on_interact():
	EventBus.start_display_message.emit(text.split("~"),title)
