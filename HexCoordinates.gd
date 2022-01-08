extends Node

class_name HexCoordinates

var x setget , get_x
var y setget , get_y
var z setget , get_z

func _init(_x, _z):
	x = _x
	z = _z

func get_x():
	return x

func get_z():
	return z

func get_y():
	return (- x - z)

func distance_to(other):
	return ((other.get_x() - get_x()) if (get_x() < other.get_x()) else (get_x() - other.get_x())
			+ (other.get_y() - get_y()) if (get_y() < other.get_y()) else (get_y() - other.get_y())
			+ (other.get_z() - get_z()) if (get_z() < other.get_z()) else (get_z() - other.get_z())) / 2
