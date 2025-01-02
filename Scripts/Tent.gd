extends StaticBody3D

@onready var interact_area: InteractObject = $"Interact Area"

func _ready() -> void:
	interact_area.interact_signal.connect(_on_interact)

func _on_interact() -> void:
	EventBus.trigger_end_day.emit()
	#interact_area.monitoring =false
