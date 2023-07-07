extends "res://SoupModOptions/OptionTypes/ModOptionObject.gd"

var stretch := TextureRect.STRETCH_KEEP_CENTERED
var texture:TextureRect
var expand := false
var size := Vector2(0, 0)

func _build():
	ignore = true # don't save anything for this value.
	
	texture = TextureRect.new()
	add_child(texture)
	texture.texture = load(display_name)
	texture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture.stretch_mode = stretch
	texture.expand = expand
	texture.set_size(size)
