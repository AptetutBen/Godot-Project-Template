class_name InteractObject extends Area3D

signal interact_signal

func interact():
	interact_signal.emit()

func _ready() -> void:
	body_entered.connect(_on_area_3d_body_entered)
	body_exited.connect(_on_area_3d_body_exited)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		EventBus.enter_interact_object.emit(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		EventBus.exit_interact_object.emit(self)
