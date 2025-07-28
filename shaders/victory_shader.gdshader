shader_type canvas_item;

group_uniforms palettes;
uniform sampler2D team_palette;
uniform sampler2D skin_palette;
uniform sampler2D victory_palette;
group_uniforms;

uniform int teams_colors[2];
uniform int skin_colors[6];

vec2 px_to_uv(ivec2 pos, ivec2 tex_size) {
	return vec2(
		(float(pos[0]) + 0.5) / float(tex_size[0]),
		(float(pos[1]) + 0.5) / float(tex_size[1])
	);
}

vec4 get_skin_color(vec4 color, sampler2D palette_skin, sampler2D palette_vic, int arr[6]) {
	ivec2 skin_tex_size = textureSize(palette_skin, 0);
	ivec2 vic_tex_size = textureSize(palette_vic, 0);
	float skin_step = 10.0;
	for (int i=0; i<skin_tex_size[0]; i++) {
		for (int j=0; j<6; j++) {
			vec2 uv_color_ref = px_to_uv(ivec2(i, j), vic_tex_size);
			vec4 color_ref = texture(palette_vic, uv_color_ref);
			if (color == color_ref) {
				vec2 uv_color_dest = px_to_uv(ivec2(i, arr[j]), skin_tex_size);
				return texture(palette_skin, uv_color_dest);
			}
		}
	}
	return color;
}

vec4 get_jersey_color(vec4 color, sampler2D palette, int home_sel, int away_sel) {
	ivec2 tex_size = textureSize(palette, 0);
	vec2 home_uv_bright = px_to_uv(ivec2(0, 0), tex_size);
	vec4 home_col_bright = texture(palette, home_uv_bright);
	vec2 home_uv_dark = px_to_uv(ivec2(1, 0), tex_size);
	vec4 home_col_dark = texture(palette, home_uv_dark);
	vec2 away_uv_bright = px_to_uv(ivec2(2, 0), tex_size);
	vec4 away_col_bright = texture(palette, away_uv_bright);
	vec2 away_uv_dark = px_to_uv(ivec2(3, 0), tex_size);
	vec4 away_col_dark = texture(palette, away_uv_dark);
	if (color == home_col_bright) {
		vec2 uv_color_dest = px_to_uv(ivec2(4, home_sel), tex_size);
		return texture(palette, uv_color_dest);
	}
	if (color == home_col_dark) {
		vec2 uv_color_dest = px_to_uv(ivec2(5, home_sel), tex_size);
		return texture(palette, uv_color_dest);
	}
	if (color == away_col_bright) {
		vec2 uv_color_dest = px_to_uv(ivec2(4, away_sel), tex_size);
		return texture(palette, uv_color_dest);
	}
	if (color == away_col_dark) {
		vec2 uv_color_dest = px_to_uv(ivec2(5, away_sel), tex_size);
		return texture(palette, uv_color_dest);
	}
	return color;
}

void fragment() {
	COLOR = get_jersey_color(COLOR, team_palette, teams_colors[0], teams_colors[1]);
	COLOR = get_skin_color(COLOR, skin_palette, victory_palette, skin_colors);
}
