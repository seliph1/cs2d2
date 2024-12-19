// GRAYSCALE BLEND MODE
shader_type canvas_item;
render_mode blend_mul;
uniform int mask_type : hint_range(1,6) = 3;
uniform float rotation_speed : hint_range(1,10) = 0.0;
uniform vec4 sprite_color = vec4(1.0);
void fragment() {
	vec4 color = COLOR;
	float average = (color.r + color.g + color.b)/3.0 ; // Calculate average and set it as the color
	COLOR.rgb = vec3(1.0-average) + color.rgb / vec3(2.0) ;
}