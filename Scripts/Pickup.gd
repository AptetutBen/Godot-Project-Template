class_name Pickup extends InteractObject

func interact():
	EventBus.pickup_object.emit(self)
	queue_free()
