# multiplayer.gd
extends Node

const PORT = 7000

func _ready():
	get_tree().paused = true
	multiplayer.server_relay = false

	if DisplayServer.get_name() == "headless":
		_on_host_pressed.call_deferred()


func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("fail")
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func _on_server_ip_text_submitted(txt):
	if txt == "":
		print("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
	
func start_game():
	# Hide the UI and unpause to start the game.
	$UI.hide()
	get_tree().paused = false
	if multiplayer.is_server():
		change_level.call_deferred(load("res://Scenes/map.tscn"))


# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())


# The server can restart the level by pressing Home.
func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("ui_home") and Input.is_action_just_pressed("ui_home"):
		print("hi hi")
		change_level.call_deferred(load("res://Scenes/map.tscn"))
