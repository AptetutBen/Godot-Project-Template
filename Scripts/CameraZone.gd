class_name CameraZone extends Area3D

@export var offset : Vector3 = Vector3(0,10,10)
@export var angle : float = 0

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("camera zone entered")
		EventBus.enter_camera_zone.emit(self)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("camera zone exited")
		EventBus.exit_camera_zone.emit(self)
