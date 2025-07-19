shader_type canvas_item;

uniform sampler2D team_palette;

uniform int home_color;
uniform int away_color;

vec2 px_to_uv(ivec2 pos, ivec2 tex_size) {
	return vec2(
		(float(pos[0]) + 0.5) / float(tex_size[0]),
		(float(pos[1]) + 0.5) / float(tex_size[1])
	);
}

vec4 get_palette_color(vec4 color, sampler2D palette, int home_sel, int away_sel) {
	ivec2 tex_size = textureSize(palette, 0);
	vec2 home_uv_ref = px_to_uv(ivec2(0, 0), tex_size);
	vec4 home_col_ref = texture(palette, home_uv_ref);
	vec2 away_uv_ref = px_to_uv(ivec2(2, 0), tex_size);
	vec4 away_col_ref = texture(palette, away_uv_ref);
	if (color == home_col_ref) {
		vec2 uv_color_dest = px_to_uv(ivec2(4, home_sel), tex_size);
		return texture(palette, uv_color_dest);
	}
	if (color == away_col_ref) {
		vec2 uv_color_dest = px_to_uv(ivec2(4, away_sel), tex_size);
		return texture(palette, uv_color_dest);
	}
	return color;
}

void fragment() {
	COLOR = get_palette_color(COLOR, team_palette, home_color, away_color);
}
