extends Node

signal enter_interact_object(_interact_object : InteractObject)
signal exit_interact_object(_interact_object : InteractObject)
signal start_conversation(_dialogue_node : DialogueConversationNodeData, _node : Node3D)
signal start_display_message(_textArray : Array[String], _title: String)
signal finish_conversation
signal pickup_object(_pickup : Pickup)
signal enter_camera_zone(_zone : CameraZone)
signal exit_camera_zone(_zone : CameraZone)
signal enable_player(_true : bool)
