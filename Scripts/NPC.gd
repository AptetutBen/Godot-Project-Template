class_name NPC extends Node

@onready var area_3d: InteractObject = %Area3D
@export var dialogue_data : DialogueData
@onready var mesh: Node3D = $Mesh

var player : Player
var start_rotation_y : float

func _ready() -> void:
	player = Player.Instance
	area_3d.interact_signal.connect(_on_interact)
	start_rotation_y = mesh.rotation.y
	EventBus.start_conversation.connect(_on_start_conversation)
	EventBus.finish_conversation.connect(_on_finish_conversation)

func _on_interact():
	var node : DialogueNodeData = dialogue_data.get_node_from_start("test")
	EventBus.start_conversation.emit(node)
	
func _on_start_conversation(_node):
	var turn_tween : Tween = get_tree().create_tween()
	var direction = (player.global_transform.origin - mesh.global_transform.origin).normalized()
	var target_rotation_y = atan2(direction.x, direction.z)
	turn_tween.tween_property(self, "rotation_degrees", Vector3(0, rad_to_deg(target_rotation_y), 0), 0.5)
	turn_tween.set_ease(Tween.EASE_OUT_IN)
	turn_tween.set_trans(Tween.TRANS_SINE)
	area_3d.monitoring = false

func _on_finish_conversation():
	var turn_tween : Tween = get_tree().create_tween()
	turn_tween.tween_property(self, "rotation_degrees", Vector3(0, rad_to_deg(start_rotation_y), 0), 0.5)
	turn_tween.set_ease(Tween.EASE_OUT_IN)
	turn_tween.set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(2).timeout
	area_3d.monitoring = true
