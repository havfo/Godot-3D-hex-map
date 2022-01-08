extends Node

class_name HexUtilities

static func from_offset_coordinates(X : int, Z : int) -> HexCoordinates:
	return HexCoordinates.new(X - Z / 2, Z)

static func from_position(position : Vector3) -> HexCoordinates:
	var x = position.x / (HexConstants.inner_radius * 2.0)
	var y = -x

	var offset = position.z / (HexConstants.outer_radius * 3.0)
	x -= offset
	y -= offset

	var iX = round_even(x)
	var iY = round_even(y)
	var iZ = round_even(-x - y)

	if iX + iY + iZ != 0:
		var dX = abs(x - iX)
		var dY = abs(y - iY)
		var dZ = abs(-x - y - iZ)
	
		if dX > dY && dX > dZ:
			iX = -iY - iZ
		elif dZ > dY:
			iZ = -iX - iY

	return HexCoordinates.new(iX, iZ)

static func round_even(value : float) -> float:
	if fmod(value, 2) == 0.5:
		return floor(value)
	else:
		return round(value)

static func get_edge_type(e1 : int, e2 : int) -> int:
	if e1 == e2:
		return HexConstants.HexEdgeType.FLAT

	var delta := abs(e1 - e2)

	if delta == 1:
		return HexConstants.HexEdgeType.SLOPE

	return HexConstants.HexEdgeType.CLIFF
