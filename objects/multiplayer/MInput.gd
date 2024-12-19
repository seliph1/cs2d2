extends Node

@export var direction = Vector2();
@onready var player = $".."

func _ready():
	#set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	direction = Input.get_vector("left", "right", "up", "down")	
		
	
func _process(_delta):
	direction = Input.get_vector("left", "right", "up", "down")	
