extends "res://SoupModOptions/ModOptionsScene.gd"


func add_image(internal_name, image, stretch=TextureRect.STRETCH_KEEP_CENTERED):
	var node = _create_generic(preload("res://OptimisedMoves/options/ImageOption.gd"), internal_name, image, 0)
	node.stretch = stretch
	
	_add_to_list(internal_name, node)
	return node
