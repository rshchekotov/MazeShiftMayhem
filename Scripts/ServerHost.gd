extends Button

@onready var serverScript = $".."

func _on_pressed():
	serverScript.create_game()
