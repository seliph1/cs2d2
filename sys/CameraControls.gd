extends Camera2D
@export var speed = 4;

func apply_movement_from_input(_delta):
	# Player movement
	var direction = Input.get_vector("left", "right", "up", "down")	
	self.position = self.position + direction * self.speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	apply_movement_from_input(delta)
