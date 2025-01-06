class_name RoadBlock extends StaticBody3D

@export var id : String

@export var title : String
@export_multiline var text : String
@onready var interact_area: InteractObject = $"Interact Area"

func _ready() -> void:
	interact_area.interact_signal.connect(_on_interact)

func _on_interact() -> void:
	EventBus.start_display_message.emit(text.split("~"),title)
