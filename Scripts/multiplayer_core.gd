extends Node

const PORT = 7000
const DEFAULT_LEVEL = "res://Scenes/map.tscn"
const DEFAULT_IP_ADRESS = "127.0.0.1"
var peer 

const SPAWN_DISPERSION_RADIUS = 3
const Player = preload("res://Scenes/multi_player.tscn")

@onready var UI = $UI
@onready var Level_Files = $Level
@onready var Player_Files = $Players

func _ready():
	get_tree().paused = true
	peer = ENetMultiplayerPeer.new()


func _on_host_pressed():
	# Start as server
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer server")
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func _on_server_ip_text_submitted(txt):
	print("hi")
	if txt == "":
		txt = DEFAULT_IP_ADRESS
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer client")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func start_game():
	UI.hide()
	get_tree().paused = false
	if multiplayer.is_server():
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(del_player)
		change_level.call_deferred(load(DEFAULT_LEVEL))
		add_player.call_deferred(multiplayer.get_unique_id())

##call only deffered, so that the level has time to load 
func change_level(scene: PackedScene):
	var level = Level_Files
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())

func add_player(id: int):
	var character = Player.instantiate()
	character.position = Vector3(SPAWN_DISPERSION_RADIUS * randf(), 0, SPAWN_DISPERSION_RADIUS * randf())
	character.name = str(id)
	character.rotation.x = 0;
	Player_Files.add_child(character, true)

func del_player(id: int):
	if not Player_Files.has_node(str(id)):
		return
	Player_Files.get_node(str(id)).queue_free()
