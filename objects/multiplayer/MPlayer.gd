extends CharacterBody2D

@export var speed := 200	
@export var player_id := 1:
	set(id):
		player_id = id
		$InputSynchronizer.set_multiplayer_authority(id)
		

func _ready():
	position = Vector2(1500,1500)
	
	if multiplayer.get_unique_id() == player_id:
		$camera.make_current()
	else:
		$camera.enabled = false	

func get_angle():
	var mouse = get_viewport().get_mouse_position()
	var center: Vector2 = get_viewport().size/2
	var mouse_angle = (mouse-center).angle()
	$sprite.rotation = mouse_angle + PI/2
func apply_movement_from_input(_delta):
	# Player movement
	var input = $InputSynchronizer
	self.velocity = input.direction * speed	
	move_and_slide()
	
	
func _physics_process(delta):
	if multiplayer.is_server():
		get_angle()
		apply_movement_from_input(delta)
	else:
		pass
	#if multiplayer.is_server():
			
