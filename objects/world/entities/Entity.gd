class_name Entity extends Node2D

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

@export var data:Dictionary = {}
@export var type:int = 1

var typename:String = ""
var simple_m = preload("res://shaders/entity.gdshader")
var light_m = preload("res://shaders/light.gdshader")
var shade_m = preload("res://shaders/shade.gdshader")
var grayscale_m = preload("res://shaders/grayscale.gdshader")
var shadow_m = preload("res://shaders/shadow4.gdshader")
var gui_icons = preload("res://gfx/gui_icons.bmp")

 
func _init(entity_data):
	if entity_data.type:
		self.type = entity_data.type
	else:
		self.type = 1
	
	self.data = entity_data
	self.typename = ENTITY_TYPE[self.type]	

func _ready() -> void:
	self.name = ENTITY_TYPE[self.type]
	if self.typename == "Env_Sprite":
		new_sprite()
		
func load_texture(path):
	var full_path = "res://" + path
	if path == "":
		return PlaceholderTexture2D.new()
	if not FileAccess.file_exists(full_path):
		#print(full_path," does not exist")
		return PlaceholderTexture2D.new()
	else:
		var sprite_texture = load(full_path)
		if sprite_texture != null:
			return sprite_texture
		else:
			return PlaceholderTexture2D.new()		

func new_sprite():
	var sprite_texture = load_texture(data.strings[0])
	var sprite = Sprite2D.new()
	var sprite_offset = Vector2(data.integers[2], data.integers[3])
	var sprite_size = sprite_texture.get_size()
	var sprite_scale = Vector2(data.integers[0], data.integers[1]) / sprite_texture.get_size()
	var sprite_center = (sprite_size * sprite_scale)/2
	var sprite_color = Color(data.integers[5]/255.0, data.integers[6]/255.0, data.integers[7]/255.0, float(data.strings[1]))
	var sprite_rotation = -data.integers[4]
	var sprite_blend_mode = data.integers[9]
	#var sprite_const_rotation = float(data.strings[3])
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

	#sprite.material.set_shader_parameter("rotation_speed",sprite.z_index*1.0)
	#sprite.material.set_shader_parameter("mask",0)
	sprite.rotation = deg_to_rad(sprite_rotation)
	sprite.modulate = sprite_color
	sprite.name = data.strings[0]
	add_child(sprite)
