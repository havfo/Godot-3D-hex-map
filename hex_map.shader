shader_type spatial;
render_mode world_vertex_coords;

varying vec3 terrain;
varying vec4 vert_color;
varying vec3 world_position;

uniform sampler2DArray color_map;
uniform float scaling_factor = 0.05;

void vertex() {
	vert_color = COLOR;
	world_position = VERTEX;
	terrain = vec3(UV.xy, UV2.x);
}

void fragment() {
	vec4 color = vec4(1.0);

	vec4 c = texture(color_map, vec3(world_position.xz * scaling_factor, terrain.x)) * vert_color.r
			+ texture(color_map, vec3(world_position.xz * scaling_factor, terrain.y)) * vert_color.g
			+ texture(color_map, vec3(world_position.xz * scaling_factor, terrain.z)) * vert_color.b;

	ALBEDO.rgb = color.rgb * c.rgb;
	ALPHA = c.a;
}