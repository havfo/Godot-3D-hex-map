extends Camera

signal tile_selected

export(float) var zoom_factor = 1
export(int) var max_zoom = 35
export(int) var min_zoom = 20

var dropPlane := Plane.PLANE_XZ
var dir := Vector3(0,0,0)
var loc := transform.origin

func _input(event):
	loc = transform.origin

	if event is InputEventMouseButton:
		dir = Vector3(0,0,0)
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				var position_2d = get_viewport().get_mouse_position()
				var position_3d = dropPlane.intersects_ray(project_ray_origin(position_2d), project_ray_normal(position_2d))
				emit_signal('tile_selected', position_3d)
			elif event.button_index == BUTTON_WHEEL_UP:
				if loc.z > min_zoom:
					dir.z -= 1
					translate(dir * zoom_factor)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				if loc.z < max_zoom:
					dir.z += 1
					translate(dir * zoom_factor)
