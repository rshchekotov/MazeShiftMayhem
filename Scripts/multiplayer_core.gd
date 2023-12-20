extends Node

#this is the main script for the game

const PORT = 7000
const DEFAULT_LEVEL = "res://Scenes/map.tscn"
var default_IP_adress = "127.0.0.1"
var peer 

const SPAWN_DISPERSION_RADIUS = 3
const Player = preload("res://Scenes/multi_player.tscn")

@onready var UI_Connection_Setup = $UI_Connection_Setup
@onready var Level_Files = $Level
@onready var Player_Files = $Players
@onready var Default_IP_Setup = $UI_Connection_Setup/HBoxContainer/VBoxContainer/ServerIP

func _ready():
	load_multiplayer_settings()
	default_IP_adress = Default_IP_Setup.placeholder_text
	get_tree().paused = true
	peer = ENetMultiplayerPeer.new()

func get_ip():
	if OS.has_feature("windows"):
		if OS.get_environment("COMPUTERNAME"):
			return IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	else:
		if OS.get_environment("HOSTNAME"):
			return IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)

func _on_host_pressed():
	# Start as server
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer server")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func _on_server_ip_text_submitted(txt):
	if txt == "":
		txt = default_IP_adress
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer client")
		return
	multiplayer.multiplayer_peer = peer
	save_multiplayer_settings()
	start_game()

func start_game():
	UI_Connection_Setup.hide()
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

func save_multiplayer_settings():
	var save_settings = FileAccess.open("res://SaveSystem/Saves/multiplayer_settings.json", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("multiplayer_settings")
	for node in save_nodes:
		if !node.has_method("save"):
			continue
		var node_data = node.call("save")
		
		var json_string = JSON.stringify(node_data)
		save_settings.store_line(json_string)

func load_multiplayer_settings():
	if not FileAccess.file_exists("res://SaveSystem/Saves/multiplayer_settings.json"):
		return
	var save_nades = FileAccess.open("res://SaveSystem/Saves/multiplayer_settings.json", FileAccess.READ)
	while save_nades.get_position() < save_nades.get_length():
		var json_string = save_nades.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK: continue
		
		# Get the data from the JSON object
		var node_data = json.get_data()
		for i in node_data.keys():
			if i == "filename": continue
			get_node(node_data["filename"]).set(i, node_data[i])
