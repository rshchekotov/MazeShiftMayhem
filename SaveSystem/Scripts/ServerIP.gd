extends LineEdit

func save():
	return {"filename": get_path(), 
			"placeholder_text": placeholder_text}
	
