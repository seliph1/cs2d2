extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var multiplayer_peer: ENetMultiplayerPeer
var multiplayer_player = preload("res://objects/multiplayer/MPlayer.tscn")
var world_scene = preload("res://objects/world/WorldScene.tscn")
var player_spawn_node
var game_space

func _ready():
	multiplayer.server_relay = false

func become_host():
	DisplayServer.window_set_title("HOST")
	print("Starting host")
	player_spawn_node = get_tree().get_current_scene().get_node("Game/Players")	
	
	game_space = get_tree().get_current_scene().get_node("Game")
	game_space.add_child( world_scene.instantiate() )
	
	var server_peer = ENetMultiplayerPeer.new(	)
	multiplayer.peer_connected.connect(add_player_to_game)
	multiplayer.peer_disconnected.connect(remove_player)
	server_peer.create_server(SERVER_PORT)
	multiplayer.set_multiplayer_peer( server_peer )
	add_player_to_game(1)
	
func join_as_player():
	DisplayServer.window_set_title("CLIENT")
	game_space = get_tree().get_current_scene().get_node("Game")
	game_space.add_child( world_scene.instantiate() )

	print("[Server] Player joining")

	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	
	multiplayer.set_multiplayer_peer( client_peer )
	

func add_player_to_game(id: int):
	var player_to_add = multiplayer_player.instantiate()

	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	player_spawn_node.add_child(player_to_add, true)
	print("[Client] Player %s joined the game!" % id )
	
func remove_player(id: int):
	print("[Client] Player %s left the game!" % id )
