shader_type canvas_item;
render_mode unshaded;
uniform ivec2 tile_size = ivec2(32);

void vertex(){
	VERTEX.x *= 2.0;
	VERTEX.y *= 2.0;
}

void fragment(){
	vec4 color = COLOR;
	
	
	
	//COLOR = color + 0.1;
}
