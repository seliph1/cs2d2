shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;
void fragment() {
	vec4 col = COLOR;
	if (col.x >= 1.0 && col.z >= 1.0 && col.y <= 0.0) {
		col.w = 0.0;
	}
	COLOR = col;
}

