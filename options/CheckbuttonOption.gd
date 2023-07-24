extends "res://SoupModOptions/OptionTypes/CheckbuttonOption.gd"


func is_inheritely_disabled():
	return btn.is_disabled() and not force_disabled

func set_disabled(value:bool):
	btn.disabled = value
	.set_disabled(value)
