extends Node

class_name HexDirection

enum {
	NE = 0,
	E = 1,
	SE = 2,
	SW = 3,
	W = 4,
	NW = 5
}

static func next(dir : int) -> int:
	return (dir + 1) % 6

static func previous(dir : int) -> int:
	return (dir - 1) % 6

static func opposite(dir : int) -> int:
	return (dir + 3) % 6

static func values() -> Array:
	return [NE, E, SE, SW, W, NW]
