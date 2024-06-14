extends Control
var quitwindow = preload("res://objects/ui/exit_confirmation.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_new_game_button_down():
	get_tree().change_scene_to_file("res://objects/world/world_scene.tscn")


func _on_quit_button_down():
	get_tree().quit()

func _on_editor_button_down():
	var instance = quitwindow.instantiate() 
	add_child(instance)
	#var text_box = exit_confirmation.instantiate()
	#pass # Replace with function body.
