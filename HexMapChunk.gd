extends Node

class_name HexMapChunk

var noise : OpenSimplexNoise
var width : int
var height : int
var fill_factor : float
var blend_factor : float
var elevation_step : float
var create_bridges : bool
var subdivide_inner_hex : bool
var perturb_vertices : bool
var noise_scale : float
var noise_amplitude : float

var tiles := []

var st : SurfaceTool

func _init(
	_noise : OpenSimplexNoise,
	_width : int,
	_height : int,
	_fill_factor : float,
	_elevation_step : float,
	_create_bridges : bool,
	_subdivide_inner_hex : bool,
	_perturb_vertices : bool,
	_noise_scale : float,
	_noise_amplitude : float
) -> void:
	noise = _noise
	width = _width
	height = _height
	fill_factor = _fill_factor
	blend_factor = 1.0 - fill_factor
	elevation_step = _elevation_step
	create_bridges = _create_bridges
	subdivide_inner_hex = _subdivide_inner_hex
	perturb_vertices = _perturb_vertices
	noise_scale = _noise_scale
	noise_amplitude = _noise_amplitude

	tiles.resize(width * height)

func add_tile(index : int, tile : HexTile) -> void:
	tiles[index] = tile

func triangulate() -> ArrayMesh:
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for tile in tiles:
		triangulate_tile(tile)

	st.index()
	st.generate_normals()

	var mesh : ArrayMesh = st.commit()

	return mesh

func triangulate_tile(tile : HexTile) -> void:
	for direction in HexDirection.values():
		triangulate_tile_direction(direction, tile)

func triangulate_tile_direction(direction : int, tile : HexTile) -> void:
	var center = tile.position
	var v1 = center + get_first_solid_corner(direction)
	var v2 = center + get_second_solid_corner(direction)

	if subdivide_inner_hex and tile.elevation > 0:
		var iv1 : Vector3 = interpolate_local(v1, center, HexConstants.inner_hex_size)
		var iv2 : Vector3 = interpolate_local(v2, center, HexConstants.inner_hex_size)

		var edge_inner := EdgeVertices.new(iv1, iv2)
		var edge_outer := EdgeVertices.new(v1, v2)

		triangulate_edge_fan(center, edge_inner, tile)
		triangulate_edge_strip(edge_inner, HexConstants.color1, tile.terrain_type_index, edge_outer, HexConstants.color1, tile.terrain_type_index)

		if direction <= HexDirection.SE and create_bridges:
			triangulate_connection(direction, tile, edge_outer)
	else:
		var edge_outer := EdgeVertices.new(v1, v2)

		triangulate_edge_fan(center, edge_outer, tile)

		if direction <= HexDirection.SE:
			triangulate_connection(direction, tile, edge_outer)

func triangulate_edge_fan(center : Vector3, edge : EdgeVertices, tile : HexTile) -> void:
	var types := Vector3(tile.terrain_type_index, tile.terrain_type_index, tile.terrain_type_index)
	add_triangle(center, HexConstants.color1, types, edge.v2, HexConstants.color1, types, edge.v1, HexConstants.color1, types)
	add_triangle(center, HexConstants.color1, types, edge.v3, HexConstants.color1, types, edge.v2, HexConstants.color1, types)
	add_triangle(center, HexConstants.color1, types, edge.v4, HexConstants.color1, types, edge.v3, HexConstants.color1, types)

func triangulate_connection(direction : int, tile : HexTile, e1 : EdgeVertices):
	var neighbor : HexTile = tile.get_neighbor(direction)

	if neighbor == null:
		return

	var bridge = get_bridge(direction)
	bridge.y = neighbor.position.y - tile.position.y
	var e2 = EdgeVertices.new(e1.v1 + bridge, e1.v4 + bridge)

	triangulate_edge_strip(e1, HexConstants.color1, tile.terrain_type_index, e2, HexConstants.color2, neighbor.terrain_type_index)

	var next_neighbor = tile.get_neighbor(HexDirection.next(direction))
	if direction <= HexDirection.E && next_neighbor != null:
		var v5 = e1.v4 + get_bridge(HexDirection.next(direction))
		v5.y = next_neighbor.elevation * elevation_step

		if tile.elevation <= neighbor.elevation:
			if tile.elevation <= next_neighbor.elevation:
				triangulate_corner(e1.v4, tile, e2.v4, neighbor, v5, next_neighbor)
			else:
				triangulate_corner(v5, next_neighbor, e1.v4, tile, e2.v4, neighbor)
		elif neighbor.elevation <= next_neighbor.elevation:
			triangulate_corner(e2.v4, neighbor, v5, next_neighbor, e1.v4, tile)
		else:
			triangulate_corner(v5, next_neighbor, e1.v4, tile, e2.v4, neighbor)

func triangulate_edge_strip(e1 : EdgeVertices, c1 : Color, type1 : float, e2 : EdgeVertices, c2 : Color, type2 : float):
	var types := Vector3(type1, type2, type1)
	add_quad(e1.v1, c1, types, e1.v2, c1, types, e2.v1, c2, types, e2.v2, c2, types)
	add_quad(e1.v2, c1, types, e1.v3, c1, types, e2.v2, c2, types, e2.v3, c2, types)
	add_quad(e1.v3, c1, types, e1.v4, c1, types, e2.v3, c2, types, e2.v4, c2, types)

func triangulate_corner(bottom : Vector3, bottom_tile : HexTile, left : Vector3, left_tile : HexTile, right : Vector3, right_tile : HexTile) -> void:
	var types := Vector3(bottom_tile.terrain_type_index, right_tile.terrain_type_index, left_tile.terrain_type_index)
	add_triangle(bottom, HexConstants.color1, types, right, HexConstants.color2, types, left, HexConstants.color3, types)

func add_triangle(
	v1 : Vector3,
	c1 : Color,
	t1 : Vector3,

	v2 : Vector3,
	c2 : Color,
	t2 : Vector3,

	v3 : Vector3,
	c3 : Color,
	t3 : Vector3
) -> void:
	st.add_uv(Vector2(t1.x, t1.y))
	st.add_uv2(Vector2(t1.z, 0.0))
	st.add_color(c1)
	if perturb_vertices:
		st.add_vertex(perturb(v1))
	else:
		st.add_vertex(v1)

	st.add_uv(Vector2(t2.x, t2.y))
	st.add_uv2(Vector2(t2.z, 0.0))
	st.add_color(c2)
	if perturb_vertices:
		st.add_vertex(perturb(v2))
	else:
		st.add_vertex(v2)

	st.add_uv(Vector2(t3.x, t3.y))
	st.add_uv2(Vector2(t3.z, 0.0))
	st.add_color(c3)
	if perturb_vertices:
		st.add_vertex(perturb(v3))
	else:
		st.add_vertex(v3)

func add_quad(
	v1 : Vector3,
	c1 : Color,
	t1 : Vector3,

	v2 : Vector3,
	c2 : Color,
	t2 : Vector3,

	v3 : Vector3,
	c3 : Color,
	t3 : Vector3,

	v4 : Vector3,
	c4 : Color,
	t4 : Vector3
) -> void:
	add_triangle(v1, c1, t1, v2, c2, t2, v3, c3, t3)
	add_triangle(v3, c3, t3, v2, c2, t2, v4, c4, t4)

func get_first_corner(direction : int) -> Vector3:
	return HexConstants.corners[direction]

func get_second_corner(direction : int) -> Vector3:
	return HexConstants.corners[direction + 1]

func get_first_solid_corner(direction : int) -> Vector3:
	return (HexConstants.corners[direction] * fill_factor) if create_bridges else HexConstants.corners[direction]

func get_second_solid_corner(direction : int) -> Vector3:
	return (HexConstants.corners[direction + 1] * fill_factor) if create_bridges else HexConstants.corners[direction + 1]

func get_bridge(direction : int) -> Vector3:
	return ((HexConstants.corners[direction] + HexConstants.corners[direction + 1]) * blend_factor) if create_bridges else ((HexConstants.corners[direction] + HexConstants.corners[direction + 1]) * 0)

static func interpolate_local(begin : Vector3, end : Vector3, change : float) -> Vector3:
	var ret := Vector3(0, 0, 0)

	ret.x = (1 - change) * begin.x + change * end.x
	ret.y = (1 - change) * begin.y + change * end.y
	ret.z = (1 - change) * begin.z + change * end.z

	return ret

func perturb(position : Vector3) -> Vector3:
	var ret = Vector3(position)

	var x_random = noise_amplitude * (noise.get_noise_3d(position.x / noise_scale, position.z / noise_scale, 0.0) * 2.0 - 1.0)
	var z_random = noise_amplitude * (noise.get_noise_3d(position.x / noise_scale, 0.0, position.z / noise_scale) * 2.0 - 1.0)

	ret.x = position.x + x_random
	ret.z = position.z + z_random

	return ret
