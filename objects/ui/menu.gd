extends Control
var ExitPopup = preload("res://objects/ui/ExitPopup.tscn")
var WorldScene = preload("res://objects/world/WorldScene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_new_game_button_down():
	var game_space = get_parent().get_node("Game")
	game_space.become_host()
	
	self.visible = false

func _on_find_servers_button_down():
	var game_space = get_parent().get_node("Game")
	game_space.join_as_player()
	
	self.visible = false


func _on_quit_button_down():
	get_tree().quit()

func _on_editor_button_down():
	get_tree().change_scene_to_file("res://Editor.tscn")
	#var instance = ExitPopup.instantiate() 
	#add_child(instance)


func _on_quick_play_button_down():
	var game_space = get_parent().get_node("Game")
	game_space.add_child( WorldScene.instantiate() )
