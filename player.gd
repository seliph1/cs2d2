extends CharacterBody2D
class_name Player
var speed: int
var camera: Camera2D

func _ready():
	speed = 200
	camera = get_node("camera")
	
func get_input():
	# Player movement
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var mouse = get_viewport().get_mouse_position()
	var center: Vector2 = get_viewport().size/2
	var mouse_angle = (mouse-center).angle()
	self.velocity = input_dir * speed
	$sprite.rotation = mouse_angle + PI/2
	#$hitbox.rotation = $sprite.rotation
	#print(mouse)
	
func _physics_process(_delta):
	get_input()
	DisplayServer.window_set_title( str(Engine.get_frames_per_second()) )
	move_and_slide()
