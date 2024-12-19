shader_type canvas_item;
render_mode unshaded;
//render_mode blend_pre;

uniform vec4 color : source_color = vec4(0.0,0.0,0.0,0.5);
uniform float angle : hint_range(0,360) = 135.0;
uniform float max_distance : hint_range(0,1000) = 50;
uniform float shadow_alpha : hint_range(0, 2) = 0.1;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {

	float angle_rad = (angle) * PI / 180.0;
	vec2 direction = vec2( sin(angle_rad), cos(angle_rad) );
	vec2 sdf_pointer = screen_uv_to_sdf(SCREEN_UV);
	float accumulated = 0.0;
	float max_dist = max_distance;
	//float max_dist = texture(height_map, SCREEN_UV).r * max_distance;
	while (accumulated <= max_dist) {
		float sdf_value = texture_sdf(sdf_pointer);
		accumulated += sdf_value;
		if (sdf_value < 0.01) {
			break;
		};
		sdf_pointer += sdf_value * direction;
	};
	float alpha = 1.0 - min(1.0, max(accumulated / max_dist, 0.0));
	alpha *= shadow_alpha;
	COLOR = vec4(color.rgb, alpha * color.a);
}

/*
void fragment(){
	//float alpha = 0.0;
	vec4 height_map = texture(SCREEN_TEXTURE, SCREEN_UV);
	float alpha = height_map.r;

	COLOR.rgb = vec3(alpha);
	//COLOR.rgb = height_map.rgb;
	//COLOR = vec4(color.rgb, alpha * color.a);
}
*/

/*
void fragment() {
    float ang_rad = angle * PI / 180.0;
    vec2 dir = vec2(sin(ang_rad),cos(ang_rad));
    vec2 at = screen_uv_to_sdf(SCREEN_UV);
	float accum = 0.0;
	float max_dist = max_distance;


    while(accum < max_dist) {
        float d = texture_sdf(at);
        accum += d;
        if (d < 0.01) {
            break;
        }
        at += d * dir;
    }
    float alpha = 1.0 - min(1.0,accum/max_dist);
    alpha = ceil(alpha);

    COLOR = vec4(color.rgb,alpha * color.a);
}
*/