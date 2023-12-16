extends TextEdit


# Called when the node enters the scene tree for the first time.

func _on_server_ui_player_connected(peer_id, player_info):
	text += "\n"
	text +=  "id: " + str(peer_id) + " info: " + player_info["name"]
