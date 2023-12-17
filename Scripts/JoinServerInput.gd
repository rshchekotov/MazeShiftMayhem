extends LineEdit
@onready var serverScript = $".."

func _on_text_submitted(new_text):
	print(new_text)
	print(serverScript.join_game(new_text))
