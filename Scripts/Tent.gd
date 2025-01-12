extends StaticBody3D

@onready var interact_area: InteractObject = $"Interact Area"

func _ready() -> void:
	interact_area.interact_signal.connect(_on_interact)

func _on_interact() -> void:
	if SaveController.is_etheral_true("can_end_day"):
		GameController.Instance.confirmation_panel.show_positive_negative(
			"End Day?",
			"Do you want to end the day",
			"Yes!",
			end_day,
			"No!",
			func():
			)
	else:
		GameController.Instance.confirmation_panel.show_positive(
			"Not yet!",
			"You can't go to bed yet",
			"Ok!",
			func():,
			)

func end_day():
	FlowController.end_day()
