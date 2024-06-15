extends TileMap
class_name MapLoader
const MAX_7B = 1 << 7
const MAX_8B = 1 << 8
const MAX_15B = 1 << 15
const MAX_16B = 1 << 16
const MAX_32B = 1 << 32
const MAX_31B = 1 << 31

const TILE_PROPERTY = {
	0: "soundless floor",
	1: "wall",
	2: "obstacle",
	3: "wall without shadow",
	4: "obstacle without shadow",
	5: "wall that is rendered at floor level",
	10: "floor dirt",
	11: "floor snow" ,
	12: "floor step",
	13: "floor tile",
	14: "floor wade",
	15: "floor metal",
	16: "floor wood",
	50: "deadly normal",
	51: "deadly toxic",
	52: "deadly explosion",
	53: "deadly abyss",
}

const ENTITY_TYPE = {
	0:"Info_T",
	1:"Info_CT",
	2:"Info_VIP",
	3:"Info_Hostage",
	4:"Info_RescuePoint",
	5:"Info_BombSpot",
	6:"Info_EscapePoint",
	7:"Info_Target",
	8:"Info_Animation",
	9:"Info_Storm",
	10:"Info_TileFX",
	11:"Info_NoBuying",
	12:"Info_NoWeapons",
	13:"Info_NoFOW",
	14:"Info_Quake",
	15:"Info_CTF_Flag",
	16:"Info_OldRender",
	17:"Info_Dom_Point",
	18:"Info_NoBuildings",
	19:"Info_BotNode",
	20:"Info_TeamGate",
	21:"Env_Item",
	22:"Env_Sprite",
	23:"Env_Sound",
	24:"Env_Decal",
	25:"Env_Breakable",
	26:"Env_Explode",
	27:"Env_Hurt",
	28:"Env_Image",
	29:"Env_Object",
	30:"Env_Building",
	31:"Env_NPC",
	32:"Env_Room",
	33:"Env_Light",
	34:"Env_LightStripe",
	35:"Env_Cube3D",
	50:"Gen_Particles",
	51:"Gen_Sprites",
	52:"Gen_Weather",
	53:"Gen_FX",
	70:"Func_Teleport",
	71:"Func_DynWall",
	72:"Func_Message",
	73:"Func_GameAction",
	80:"Info_NoWeather",
	81:"Info_RadarIcon",
	90:"Trigger_Start",
	91:"Trigger_Move",
	92:"Trigger_Hit",
	93:"Trigger_Use",
	94:"Trigger_Delay",
	95:"Trigger_Once",
	96:"Trigger_If",
}


var mapdata = {}
#var map_path = "res://maps/fun_roleplay.map"
var map_path = "res://maps/as_snow.map"
var mapfile : FileAccess

var simple_m = preload("res://shaders/entity.gdshader")
var light_m = preload("res://shaders/light.gdshader")
var shade_m = preload("res://shaders/shade.gdshader")
var grayscale_m = preload("res://shaders/grayscale.gdshader")
var shadow_m = preload("res://shaders/shadow.gdshader")

var sprite_resource = {}

func read_byte(file: FileAccess) -> int:
	var byte = file.get_8()
	return byte
	
func read_integer(file: FileAccess) -> int:
	var bit32 = file.get_32()
	return (bit32 + MAX_15B) % MAX_16B - MAX_15B
	
func read_short(file: FileAccess) -> int:
	var short = file.get_16()
	return short

func read_string(file: FileAccess):
	var array = PackedByteArray()
	var byte_s : int
	while byte_s != 0x0a and not file.eof_reached(): # \n (newline)
		byte_s = file.get_8()
		if byte_s != 0x0a and byte_s != 0x0d:
			array.append(byte_s)

	return array.get_string_from_utf8()

func seek_forward(file: FileAccess, amount: int):
	file.seek(file.get_position() + amount)

func _ready():
	mapfile = FileAccess.open(map_path, FileAccess.READ)
	# MAP SETTINGS/BYTE
	mapdata.header = read_string(mapfile)
	mapdata.scroll = read_byte(mapfile)
	mapdata.modifiers = read_byte(mapfile)
	mapdata.save_tile_heights = read_byte(mapfile)
	mapdata.pixel_tiles_hd = read_byte(mapfile)
	seek_forward(mapfile, 6)
	# MAP SETTINGS/INTEGER
	mapdata.uptime = read_integer(mapfile)
	mapdata.usgn = read_integer(mapfile)-52
	mapdata.daylight = read_integer(mapfile)
	seek_forward(mapfile, 7*4)
	# MAP SETTINGS/STRING
	mapdata.author = read_string(mapfile)
	mapdata.version = read_string(mapfile)
	seek_forward(mapfile, 8*2)
	# MORE MAP SETTINGS
	mapdata.moresettings = read_string(mapfile)
	mapdata.tileset_filename = read_string(mapfile)
	mapdata.tileset_path = "res://gfx/tiles/" + mapdata.tileset_filename
	mapdata.tile_count = read_byte(mapfile)
	mapdata.width = read_integer(mapfile)
	mapdata.height = read_integer(mapfile)
	mapdata.background = {
		path = read_string(mapfile),
		scroll_x = read_integer(mapfile),
		scroll_y = read_integer(mapfile),
		rgb = [read_byte(mapfile),read_byte(mapfile),read_byte(mapfile)], 
	}
	
	# FOOTER TESTER FOR FILE CORRUPTION
	mapdata.footer =  read_string(mapfile)

	#TILE PROPERTY
	mapdata.tile_property = {}
	for i in range(mapdata.tile_count+1):
		mapdata.tile_property[i] = read_byte(mapfile)
	
	#TILE HEIGHT
	mapdata.tile_height = {}
	mapdata.tile_3d = {}
	for i in range(mapdata.tile_count+1):
		if mapdata.save_tile_heights == 1:
			mapdata.tile_height[i] = read_integer(mapfile)
		elif mapdata.save_tile_heights == 2:
			mapdata.tile_height[i] = read_short(mapfile)
			mapdata.tile_3d[i] = read_byte(mapfile)

	# MAP
	var tileset_texture = load(mapdata.tileset_path)
	var tileset_source = TileSetAtlasSource.new()
	var tile_size = Vector2i(32,32)
	var tile_shape = PackedVector2Array([
		Vector2( -tile_size.x, -tile_size.y)/2,
		Vector2( -tile_size.x,  tile_size.y)/2,
		Vector2(  tile_size.x,  tile_size.y)/2,
		Vector2(  tile_size.x, -tile_size.y)/2
	])
	var tile_occluder = OccluderPolygon2D.new()
	tile_occluder.polygon = tile_shape
	self.tile_set = TileSet.new()
	self.tile_set.tile_size = Vector2i(32,32)
	self.tile_set.add_physics_layer(0)
	self.tile_set.add_occlusion_layer(0)
	self.tile_set.set_occlusion_layer_sdf_collision(0, true)
	self.tile_set.set_occlusion_layer_light_mask(0,1)
	self.tile_set.add_source(tileset_source, 0)
	
	tileset_source.margins = Vector2i(0,0)
	tileset_source.separation = Vector2i(0,0)
	tileset_source.texture_region_size = tile_size
	tileset_source.use_texture_padding = true
	tileset_source.texture = tileset_texture
	
	var max_width  = roundi( tileset_texture.get_width()/32)
	var max_height = roundi( tileset_texture.get_height()/32)
	
	for tx in range(max_width):
		for ty in range(max_height):
			var atlas_coords = Vector2i(tx,ty)
			tileset_source.create_tile(atlas_coords)
			var tile_data = tileset_source.get_tile_data(atlas_coords,0)
			var tile_id = ty * max_width + tx
			var tile_property = TILE_PROPERTY[mapdata.tile_property[tile_id]]
			if tile_property == "wall": 
				tile_data.z_index = 32
				tile_data.add_collision_polygon(0)
				tile_data.set_occluder(0,tile_occluder)
				tile_data.set_collision_polygon_points(0, 0, tile_shape)
			elif tile_property == "obstacle":
				tile_data.z_index = 16
				tile_data.add_collision_polygon(0)
				tile_data.set_occluder(0,tile_occluder)
				tile_data.set_collision_polygon_points(0, 0, tile_shape)
			else:
				tile_data.z_index = 0


	mapdata.tilemap = []
	for x in range(mapdata.width+1):
		mapdata.tilemap.append([])
		for y in range(mapdata.height+1):
			mapdata.tilemap[x].append([])
			mapdata.tilemap[x][y] = {
				tile_id = read_byte(mapfile),
				tile_mod = 0,
				tile_color = {r=0,g=0,b=0,o=0},
				orientation = 0,
				something = "",
			}
	

	for x in range(mapdata.width+1):
		for y in range(mapdata.height+1):
			var map_coords = Vector2i(x,y)
			var modifier : int  = 0
			if mapdata.modifiers==1:
				modifier = read_byte(mapfile)
				mapdata.tilemap[x][y].orientation = modifier
				if modifier >= 192:
					mapdata.tilemap[x][y].something = read_string(mapfile)
				elif modifier >= 64 and modifier < 128:
					mapdata.tilemap[x][y].tile_mod = read_byte(mapfile)
				elif modifier >= 128:	
					mapdata.tilemap[x][y].tile_color = {
						r = read_byte(mapfile),
						g = read_byte(mapfile),
						b = read_byte(mapfile),
						o = read_byte(mapfile),
					}
				
			var tile_id = mapdata.tilemap[x][y].tile_id
			var tile_coords_x = tile_id % max_width
			var tile_coords_y = floori(tile_id / max_width)
			var tile_coords:Vector2i = Vector2i(tile_coords_x , tile_coords_y)
			var rotation_offset = 0
			if modifier == 3:
				rotation_offset = tileset_source.TRANSFORM_TRANSPOSE | tileset_source.TRANSFORM_FLIP_V
			elif modifier == 1:
				rotation_offset = tileset_source.TRANSFORM_TRANSPOSE |  tileset_source.TRANSFORM_FLIP_H
			elif modifier == 2:
				rotation_offset = tileset_source.TRANSFORM_FLIP_V | tileset_source.TRANSFORM_FLIP_H
			
			self.set_cell(0, map_coords, 0, tile_coords, rotation_offset)
							
			#var label = Label.new()
			#label.text = str(x) + "," + str(y)
			#label.text = str(tile_id)
			#label.position = Vector2(x*32,y*32)
			#label.z_index = 99
			#add_child(label)
	
	#var shadow_layer = Polygon2D.new()
	#shadow_layer.color = Color(1.0, 1.0, 1.0);
	#shadow_layer.z_index = 1
	#shadow_layer.polygon = PackedVector2Array([
	#	Vector2(mapdata.width * 32 * 0, mapdata.height * 32 * 0),
	#	Vector2(mapdata.width * 32 * 0, mapdata.height * 32 * 1),
	#	Vector2(mapdata.width * 32 * 1, mapdata.height * 32 * 1),
	#	Vector2(mapdata.width * 32 * 1, mapdata.height * 32 * 0),
	#])
	
	#shadow_layer.material = ShaderMaterial.new()
	#shadow_layer.material.set_shader(shadow_m) 
	#shadow_layer.material.set("shader_param/color", Vector4(0.0, 0.0, 0.0, 0.5))	
	#add_child(shadow_layer)
	
	mapdata.entity_count = read_integer(mapfile)
	mapdata.entity = []
	for i in range(mapdata.entity_count):
		var data = {
			label = read_string(mapfile),
			type = read_byte(mapfile),
			pos = Vector2(read_integer(mapfile), read_integer(mapfile)),
			trigger = read_string(mapfile),
			strings = [],
			integers = [],
		}
		for j in range(10):
			data.integers.append(read_integer(mapfile))
			data.strings.append(read_string(mapfile))
		mapdata.entity.append(data)	
		
		if ENTITY_TYPE[data.type] == "Env_Sprite":
			new_sprite(data)
		elif ENTITY_TYPE[data.type] == "Env_Object":
			load_object(data)

func load_object(data):
	pass

func load_texture(path):
	var full_path = "res://" + path
	if path == "":
		return PlaceholderTexture2D.new()
	if not FileAccess.file_exists(full_path):
		#print(full_path," does not exist")
		return PlaceholderTexture2D.new()
	elif sprite_resource.has(full_path):
		#print(full_path," reloaded from cache")
		return sprite_resource[full_path]
	else:
		#print(full_path," created in cache")
		sprite_resource[full_path] = load(full_path)
		return sprite_resource[full_path]

func new_sprite(data):
	var sprite_texture = load_texture(data.strings[0])
	var sprite = Sprite2D.new()
	var sprite_offset = Vector2(data.integers[2], data.integers[3])
	var sprite_size = sprite_texture.get_size()
	var sprite_scale = Vector2(data.integers[0], data.integers[1]) / sprite_texture.get_size()
	var sprite_center = (sprite_size * sprite_scale)/2
	var sprite_color = Color(data.integers[5]/255.0, data.integers[6]/255.0, data.integers[7]/255.0, float(data.strings[1]))
	var sprite_rotation = -data.integers[4]
	var sprite_blend_mode = data.integers[9]
	var sprite_const_rotation = float(data.strings[3])
	var sprite_cover
	if data.strings[4] == "1":
		sprite_cover = 1
	elif data.strings[4] == "":
		sprite_cover = 33
	
	sprite.texture = sprite_texture
	sprite.position = (data.pos * 32) + sprite_offset + sprite_center
	sprite.scale = sprite_scale
	sprite.z_index = sprite_cover
	sprite.material = ShaderMaterial.new()
	if sprite_blend_mode == 3:
		sprite.material.set_shader(light_m)
	elif sprite_blend_mode == 4:	
		sprite.material.set_shader(shade_m)
	elif sprite_blend_mode == 6:		
		sprite.material.set_shader(grayscale_m)
	else:
		sprite.material.set_shader(simple_m)
	
	sprite.material.set_shader_parameter("rotation_speed",sprite.z_index*1.0)
	sprite.material.set_shader_parameter("mask",0)
	sprite.rotation = deg_to_rad(sprite_rotation)
	
	sprite.modulate = sprite_color
	add_child(sprite)
