@tool
extends Node3D

class_name HeightmapGenerator

# Exported properties
@export var map_size: int = 256
@export var raycast_height: float = 100.0
@export var raycast_depth: float = 200.0
@export var output_file: String = "res://heightmap.png"

func _ready() -> void:
	_generate_heightmap()

func _generate_heightmap():
	#if not Engine.is_editor_hint():
		#return

	var output_image = Image.create(map_size, map_size, false, Image.FORMAT_RGBAF)

	var half_size = map_size / 2
	for x in range(map_size):
		for y in range(map_size):
			var world_x = (x - half_size) / half_size * raycast_height
			var world_y = (y - half_size) / half_size * raycast_height

			var from_pos = Vector3(world_x, raycast_height, world_y)
			var to_pos = Vector3(world_x, -raycast_depth, world_y)

			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
			var result = space_state.intersect_ray(query)

			var height = 0.0
			if result.has("position"):
				height = (raycast_height - result["position"].y) / raycast_height
				print(height)
				
			var test : Vector2i = output_image.get_size()
			output_image.set_pixel(x, y, Color(height, height, height))

	output_image.flip_y()
	output_image.save_png(output_file)

# Editor function to trigger heightmap generation
func _on_generate_pressed():
	_generate_heightmap()

# Editor UI setup
func _get_configuration_warning() -> String:
	return "Ensure this node is placed at the center of the area you want to map, and that the level geometry is loaded."
