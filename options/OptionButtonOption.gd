extends "res://SoupModOptions/OptionTypes/OptionButtonOption.gd"


func is_inheritely_disabled():
	return optionbutton.is_disabled() and not force_disabled

func set_disabled(value:bool):
	if value:
		label.add_color_override("font_color", get_color("font_color_disabled", "Button"))
	else:
		label.remove_color_override("font_color")
	optionbutton.disabled = value
	.set_disabled(value)
