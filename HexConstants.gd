extends Node

class_name HexConstants

# Size of hexes
const outer_radius := 1.0
const inner_radius := outer_radius * 0.866025404
const inner_hex_size := 0.5

# Vertex colors for texture mixing
const color1 := Color(1, 0, 0, 1)
const color2 := Color(0, 1, 0, 1)
const color3 := Color(0, 0, 1, 1)

enum HexEdgeType {
	FLAT, SLOPE, CLIFF
}

const corners := [
	Vector3(0.0, 0.0, outer_radius),
	Vector3(inner_radius, 0.0, 0.5 * outer_radius),
	Vector3(inner_radius, 0.0, -0.5 * outer_radius),
	Vector3(0.0, 0.0, -outer_radius),
	Vector3(-inner_radius, 0.0, -0.5 * outer_radius),
	Vector3(-inner_radius, 0.0, 0.5 * outer_radius),
	Vector3(0.0, 0.0, outer_radius)
]
