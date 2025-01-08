@tool
extends Node3D

class_name HeightmapGenerator

@export_tool_button("Create Heightmap")
var callable : Callable = _generate_heightmap

@export var terrain_3d: Terrain3D
@export var section : Vector2i = Vector2i(0,0)
@export var colliders_to_ignore : Array[Node3D]

# Exported properties
@export var map_size: int = 128
@export var zoom: float = 1
@export var raycast_height: float = 50.0
@export var raycast_depth: float = -10.0
@export var distance_falloff: float = 10
@export var mask_value: float = 0.1

@export var save_directory: String = "res://Data/Sea/"
var output_file_name: String = "heightmap"
var mask_file_name: String = "heightmap"
var sdf_output_file_name: String = "sdf"

@export var show_non_hits: bool = false
@export var save_mask: bool = false

var true_zoom : float

func _generate_heightmap():
	if not Engine.is_editor_hint():
		return
	
	for item in colliders_to_ignore:
		if item is CollisionShape3D:
			item.disabled = true
		elif item is CollisionPolygon3D:
			item.disabled = true
			
	terrain_3d.collision_mode = Terrain3D.FULL_EDITOR
	
	true_zoom = pow(2,zoom-1)
	print("Generating Height Map...")
	var output_image = Image.create(map_size * true_zoom, map_size * true_zoom, false, Image.FORMAT_RGBAF)

	var world_x : int = section.x * map_size
	var world_z : int = section.y * map_size

	var from_pos : Vector3 = Vector3(world_x, raycast_height, world_z)
	var to_pos : Vector3  = Vector3(world_x, raycast_depth, world_z)

	var space_state = get_world_3d().direct_space_state

	for x in range(map_size * true_zoom):
		for y in range(map_size * true_zoom):
			
			var cast_pos : Vector3 = Vector3(x,0,y) / true_zoom

			var query = PhysicsRayQueryParameters3D.create(cast_pos+from_pos, cast_pos+to_pos)
			var result = space_state.intersect_ray(query)

			var height = 0.0
			if result.has("position"):
				height = (raycast_height - result["position"].y) / raycast_height
				output_image.set_pixel(x, y, Color(height, height, height))
			else:
				if show_non_hits:
					output_image.set_pixel(x, y, Color(1, 0, 0))
				else:
					output_image.set_pixel(x, y, Color(1, 1, 1))
					
	var save_path : String = "%s%s %s,%s.png"%[save_directory,output_file_name, section.x,section.y]
	print(save_path)
	output_image.save_png(save_path)
	print("Finished Generating Height Map.")

	var mask : Image = _create_mask(output_image)
	_create_signed_distance_field(mask)
	
	terrain_3d.collision_mode = Terrain3D.FULL_GAME
	for item in colliders_to_ignore:
		if item is CollisionShape3D:
			item.disabled = false
		elif item is CollisionPolygon3D:
			item.disabled = false

func _create_mask(image: Image) -> Image:
	print("Generating Mask...")
	var image_size : int = image.get_width()
	var mask = Image.create(image_size, image_size, false, Image.FORMAT_L8)

	for x in range(image_size):
		for y in range(image_size):
			var pixel = image.get_pixel(x, y).r
			mask.set_pixel(x, y, Color.WHITE if pixel > mask_value else Color.BLACK)

	if save_mask:
		mask.save_png("%s%s %s,%s.png"%[save_directory,mask_file_name, section.x,section.y])
		
	print("Finished Generating Mask.")
	return mask

	# Helper function to check if a point is within bounds
func is_in_bounds(x: int, y: int, image_size : int) -> bool:
		return x >= 0 and x < image_size and y >= 0 and y < image_size

func _create_signed_distance_field(image: Image) -> void:
	print("Generating Signed Distance Field...")

	var image_size: int = image.get_width()
	assert(image.get_width() == image.get_height(), "Image must be square.")

	# Initialize the SDF image
	var sdf: Image = Image.create(image_size, image_size, false, Image.FORMAT_RGBAF)
	var actual_falloff: float = distance_falloff * zoom

	# Precompute a list of all edge pixels
	var edge_pixels: Array = []
	for x in range(image_size):
		for y in range(image_size):
			var current_pixel: bool = image.get_pixel(x, y).r > 0.5
			for dir in [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]:
				var nx: int = x + int(dir.x)
				var ny: int = y + int(dir.y)
				if nx >= 0 and nx < image_size and ny >= 0 and ny < image_size:
					var neighbor_pixel: bool = image.get_pixel(nx, ny).r > 0.5
					if current_pixel != neighbor_pixel:
						edge_pixels.append(Vector2(x, y))
						break

	# Calculate the Signed Distance Field
	for x in range(image_size):
		for y in range(image_size):
			var current_pixel: bool = image.get_pixel(x, y).r > 0.5
			var nearest_dist: float = actual_falloff
			for edge in edge_pixels:
				var dist: float = (Vector2(x, y) - edge).length()
				if dist < nearest_dist:
					nearest_dist = dist

			# Invert distance for background pixels
			if not current_pixel:
				nearest_dist = -nearest_dist

			# Normalize the distance value and set the pixel
			var distance_value: float = 0.5 + (nearest_dist / actual_falloff) * 0.5
			distance_value = clamp(distance_value, 0.0, 1.0)  # Ensure values are clamped between 0 and 1
			sdf.set_pixel(x, y, Color(1-distance_value, 1-distance_value, 1-distance_value))

	# Save the resulting SDF image
	var save_path: String = "%s/%s %d,%d.png" % [save_directory, sdf_output_file_name, section.x, section.y]
	sdf.save_png(save_path)

	print("Finished Generating Signed Distance Field.")
