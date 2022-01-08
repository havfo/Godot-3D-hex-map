tool
extends Spatial

class_name HexMap

export (int, 1, 40) var width
export (int, 1, 40) var height
export (int, 1, 10) var chunk_width
export (int, 1, 10) var chunk_height
export (float) var elevation_step := 0.4
export (bool) var create_bridges := true
export (bool) var subdivide_inner_hex := true
export (float) var fill_factor := 0.8
export (bool) var perturb_vertices := false
export (float) var noise_scale := 1.0
export (float) var noise_amplitude := 0.5

export (TextureArray) var terrain_texture

var title = 'Hex v0.1'

# Width = X , height = Z
var tile_count_z : int
var tile_count_x : int

var surface_material : Material = preload('res://hex_map.tres')

var tiles := []
var chunks := []
var meshes := []
var meshInstance : MeshInstance
var noise : OpenSimplexNoise = OpenSimplexNoise.new()

onready var camera = find_node('Camera')

func _ready() -> void:
	camera.connect('tile_selected', self, '_tile_selected')

	randomize()

	noise.seed = randi()
	noise.octaves = 4
	noise.period = 10.0
	noise.persistence = 0.8
	
	surface_material.set_shader_param('color_map', terrain_texture)

	create_map()

func _process(_delta : float) -> void:
	OS.set_window_title(title + " | fps: " + str(Engine.get_frames_per_second()))

func create_chunks() -> void:
	chunks.resize(width * height)

	var i := 0
	for _z in range(height):
		for _x in range(width):
			chunks[i] = HexMapChunk.new(
				noise,
				chunk_width,
				chunk_height,
				fill_factor,
				elevation_step,
				create_bridges,
				subdivide_inner_hex,
				perturb_vertices,
				noise_scale,
				noise_amplitude
			)
			i += 1

func create_tiles() -> void:
	tiles.resize(tile_count_x * tile_count_z)

	var i := 0
	for z in range(tile_count_z):
		for x in range(tile_count_x):
			create_tile(x, z, i)
			i += 1

func create_tile(x : int, z : int, i : int) -> void:
	var position := Vector3((x + z * 0.5 - z / 2) * (HexConstants.inner_radius * 2), 0, z * (HexConstants.outer_radius * 1.5))

	tiles[i] = HexTile.new(position)
	tiles[i].coordinates = HexUtilities.from_offset_coordinates(x, z)

	# Sets a random texture
	tiles[i].terrain_type_index = randi() % 8
	# Sets a random elevation
	tiles[i].set_elevation(randi() % 3 - 1, elevation_step)
	
	if x > 0:
		tiles[i].set_neighbor(HexDirection.W, tiles[i - 1])

	if z > 0:
		if (z & 1) == 0:
			tiles[i].set_neighbor(HexDirection.SE, tiles[i - tile_count_x])
			if x > 0:
				tiles[i].set_neighbor(HexDirection.SW, tiles[i - tile_count_x - 1])
		else:
			tiles[i].set_neighbor(HexDirection.SW, tiles[i - tile_count_x])
			if x < tile_count_x - 1:
				tiles[i].set_neighbor(HexDirection.SE, tiles[i - tile_count_x + 1])

	add_tile_to_chunk(x, z, tiles[i])

func add_tile_to_chunk(x : int, z : int, tile : HexTile) -> void:
	var chunk_x : int = x / chunk_width
	var chunk_z : int = z / chunk_height

	var chunk : HexMapChunk = chunks[chunk_x + (chunk_z * width)]

	var local_x = x - (chunk_x * chunk_width)
	var local_z = z - (chunk_z * chunk_height)

	chunk.add_tile(local_x + (local_z * chunk_width), tile)

func triangulate():
	for chunk in chunks:
		var mesh = chunk.triangulate()
	
		meshInstance = MeshInstance.new()
		meshInstance.set_mesh(mesh)

		meshInstance.set_surface_material(0, surface_material)

		meshes.append(meshInstance)

		add_child(meshInstance)

func _tile_selected(position : Vector3) -> void:
	var tile := get_tile(position)

func get_tile(position : Vector3) -> HexTile:
	var coordinates := HexUtilities.from_position(position)
	# print('x : ' + str(coordinates.x) + '  z : ' + str(coordinates.z))
	var index = coordinates.x + (coordinates.z * tile_count_x) + (coordinates.z / 2);
	return tiles[index]

func create_map() -> void:
	tile_count_z = height * chunk_height
	tile_count_x = width * chunk_width

	chunks.clear()
	tiles.clear()

	if meshes.size() > 0:
		for mesh in meshes:
			remove_child(mesh)

	meshes.clear()

	create_chunks()
	create_tiles()
	triangulate()
