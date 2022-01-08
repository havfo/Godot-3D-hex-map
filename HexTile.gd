extends Node

class_name HexTile

var position : Vector3
var coordinates : HexCoordinates
var neighbors = []
var elevation := 0
var terrain_type_index : int

func _init(_position : Vector3) -> void:
	position = _position
	neighbors.resize(6)

func set_neighbor(direction : int, tile : HexTile) -> void:
	neighbors[direction] = tile
	tile.set_opposite_neighbor(HexDirection.opposite(direction), self)

func set_opposite_neighbor(direction : int, tile : HexTile) -> void:
	neighbors[direction] = tile

func get_neighbor(direction : int) -> HexTile:
	return neighbors[direction]

func set_elevation(value : int, elevation_step : float) -> void:
	elevation = value
	position.y = elevation * elevation_step

func get_direction_edge_type(direction : int) -> int:
	return HexUtilities.get_edge_type(elevation, neighbors[direction].elevation)

func get_tile_edge_type(tile : HexTile) -> int:
	return HexUtilities.get_edge_type(elevation, tile.elevation)
