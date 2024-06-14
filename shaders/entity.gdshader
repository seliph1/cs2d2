// NORMAL (DEFAULT) BLEND MODE
shader_type canvas_item;
//render_mode skip_vertex_transform;
uniform int mask_type : hint_range(1,6) = 3;
uniform float rotation_speed : hint_range(1,10) = 1.0;

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void vertex() {
	//VERTEX += vec2(10.0, 0.0);
	//VERTEX += vec2(cos(TIME)*10.0, sin(TIME)*10.0);
	//VERTEX.t += 15.0;
	float angle = TIME * rotation_speed ;
	mat2 transform = mat2(
		vec2(sin(angle),-cos(angle)),
		vec2(cos(angle),sin(angle))
	);
	//VERTEX *= transform;
	//mat2 transform = mat2(1.0);
	//VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}
void fragment() {
	//vec2 rotated_uv = rotate(UV, vec2(0.5), TIME);
	//COLOR = texture(TEXTURE, rotated_uv);
}