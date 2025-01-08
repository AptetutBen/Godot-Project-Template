class_name DialogueConversationNodeData extends Resource

@export var text : String
@export var id : int
@export var options : Array[DialogueOption]
@export var character_id : int

var dialoge_data : DialogueData
@export var position : Vector2

func get_character() -> DialogueCharacter:
	return dialoge_data.characters.get_character(character_id)
	
