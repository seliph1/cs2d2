shader_type canvas_item;

uniform sampler2D map_tileset;
uniform sampler2D map_data; // Test
uniform ivec2 tile_size = ivec2(32);
uniform ivec2 map_size = ivec2(500);


void vertex() {
	// Called for every vertex the material is visible on.
}
void fragment() {
	//vec2 txr_size = vec2(txr_width, txr_height);
	/*
	COLOR = texture(TEXTURE,
		(mod(UV * txr_size, 1) * tile_width // offset
		+ vec2(floor(texture(TEXTURE, UV).r * tile_count) * tile_width., txr_height - tile_height) // map
		/ txr_size // normalize
	);*/
}
