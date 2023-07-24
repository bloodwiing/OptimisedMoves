extends "res://SoupModOptions/OptionTypes/ModOptionObject.gd"


var btn:Button
var label:Label


func _build():
	ignore = true
	
	var hsep := HBoxContainer.new()
	btn = Button.new()
	label = Label.new()
	hsep.add_child(label)
	hsep.add_child(btn)
	add_child(hsep)
	label.text = display_name
	btn.text = default_value
	hsep.size_flags_horizontal = SIZE_EXPAND_FILL
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	btn.size_flags_horizontal = SIZE_EXPAND_FILL
	
	btn.connect("pressed", self, "option_changed")

func option_changed():
	emit_signal("option_changed", fullpath, true)

func is_inheritely_disabled():
	return btn.is_disabled() and not force_disabled

func set_disabled(value:bool):
	if value:
		label.add_color_override("font_color", get_color("font_color_disabled", "Button"))
	else:
		label.remove_color_override("font_color")
	btn.disabled = value
	.set_disabled(value)
