extends Node

class_name EdgeVertices

var v1
var v2
var v3
var v4

func _init(corner1, corner2):
	self.v1 = corner1
	self.v2 = corner1.linear_interpolate(corner2, 1.0 / 3.0)
	self.v3 = corner1.linear_interpolate(corner2, 2.0 / 3.0)
	self.v4 = corner2
