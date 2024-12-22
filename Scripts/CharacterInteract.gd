class_name CharacterInteract extends InteractObject

signal on_interact

func interact():
	on_interact.emit(self)
