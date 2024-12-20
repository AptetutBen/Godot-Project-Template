class_name InteractObject extends Node3D

func interact():
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		EventBus.enter_interact_object.emit(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		EventBus.exit_interact_object.emit(self)
