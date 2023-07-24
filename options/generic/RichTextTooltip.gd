extends PanelContainer


var label:RichTextLabel


func _init(text).():
	theme = preload("res://theme.tres")
	add_stylebox_override("panel", preload("res://OptimisedMoves/options/generic/tooltip_bordered.stylebox"))
	rect_clip_content = false
	mouse_filter = MOUSE_FILTER_IGNORE
	
	label = RichTextLabel.new()
	label.fit_content_height = true
	label.bbcode_enabled = true
	label.bbcode_text = text
	label.rect_clip_content = false
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.set_custom_minimum_size(Vector2(200, 0))
	add_child(label)
